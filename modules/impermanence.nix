/*
Impermanence implementation for sopsnix based ZFS wiping impermanenece.

It assumes
- one normal user + root,
- the persistent directory is mounted at /persistent
- your zfs setup has zroot/nixos/root@blank and zroot/nixos/home@blank
- user ID and group ID are configurable (defaults to 1000:1000)
*/
{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf concatStringsSep all;
  cfg = config.atro.impermanence;

  mkDirsForHome =
    [
      ".config"
      ".local"
      ".cache"
      ".ssh"
      ".local/share"
    ]
    ++ cfg.home.ensureDirsExist;
  mkDirForensureDirsExist = "mkdir -p ${mkDirsForHome |> map (d: "/home/${cfg.userName}/" + d) |> concatStringsSep " "}";
  initrdScript = ''
    echo "--------------------------------------------------"
    echo "Setting up impermanence..."

    echo "Rolling root back to blank..."
    zfs rollback -r zroot/nixos/root@blank

    echo "Rolling home back to blank..."
    zfs rollback -r zroot/nixos/home@blank

    echo "Impermanence setup complete."
    echo "--------------------------------------------------"
    echo "Fixing permissions..."

    echo "Mounting home..."
    mkdir -p /home
    mount -t zfs zroot/nixos/home /home

    echo "Mounting persistent..."
    mkdir -p /persistent
    mount -t zfs zroot/nixos/persistent /persistent

    echo "Fixing permissions for home..."
    ${mkDirForensureDirsExist}
    chown -R ${toString cfg.userId}:${toString cfg.groupId} /home/${cfg.userName}

    mkdir -p /persistent/home/${cfg.userName}
    HOME_OWNER=$(stat -c '%u' "/persistent/home/${cfg.userName}") # Optimising, only chown if the whole dir is not belonging to the user.
    if [ "$HOME_OWNER" -ne "${toString cfg.userId}" ]; then
     echo "Fixing permissions for persistent..."
     chown -R ${toString cfg.userId}:${toString cfg.groupId} /persistent/home/${cfg.userName}
    fi

    echo "Unmounting home..."
    umount /home

    echo "Fixing permissions for other dirs..."
    mkdir -p /persistent/var/lib/private
    chmod 700 /persistent/var/lib/private

    echo "Unmounting persistent..."
    umount /persistent

    echo "Permissions fixed."
    echo "--------------------------------------------------"
  '';
  objType = types.listOf (types.oneOf [types.str types.attrs]);
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.atro.impermanence = {
    enable = mkEnableOption "zfs with impermanence";
    rootPrivateKeyPath = mkOption {
      type = types.str;
      default = "/persistent/root/.ssh/id_ed25519";
      description = ''
        Path to the root private key on the persistent directory.
      '';
    };
    userName = mkOption {
      type = types.str;
      description = ''
        Non-root user to use impermanence with.
      '';
    };
    userId = mkOption {
      type = types.int;
      default = 1000;
      description = ''
        The user ID (UID) of the non-root user.

        This must match the actual UID of the user specified in userName.
        The default is 1000, which is the standard UID for the first non-root user.

        If misconfigured, files will have incorrect ownership after boot, potentially
        preventing login or causing permission errors.
      '';
    };
    groupId = mkOption {
      type = types.int;
      default = 1000;
      description = ''
        The group ID (GID) of the non-root user.

        This must match the actual GID of the user specified in userName.
        The default is 1000, which is the standard GID for the first non-root user.
      '';
    };
    global = {
      dirs = mkOption {
        type = objType;
        default = [];
        description = ''
          List of global directories to map.

          For example
          ["/root/.ssh", "/var/lib/bluetooth"] would map /persistent/root/.ssh and /persistent/var/lib/bluetooth to
          /root/.ssh and /var/lib/bluetooth respectively.
        '';
      };
      files = mkOption {
        type = objType;
        default = [];
        description = ''
          List of global files to map.

          For example
          ["/etc/machine-id"] would map /persistent/etc/machine-id to /etc/machine-id.
        '';
      };
    };
    home = {
      dirs = mkOption {
        type = objType;
        default = [];
        description = ''
          List of home directories to map.

          For example
          [".ssh", ".wakatime"] would map /persistent/home/<user>/.ssh and /persistent/home/<user>/.wakatime to
          /home/<user>/.ssh and /home/<user>/.wakatime respectively.
        '';
      };
      ensureDirsExist = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Directories to create in the user's home directory if they do not exist.

          Do note some directories will always be created, such as .config, .local, .cache, .ssh and .local/share.
          This is necessary as otherwise these directories would be made by root:root and not allow the user to login.
        '';
      };
      files = mkOption {
        type = objType;
        default = [];
        description = ''
          List of home files to map.

          For example
          [".kube/config"] would map /persistent/home/<user>/.kube/config to /home/<user>/.kube/config.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = all (x: !lib.strings.hasPrefix "/home" x) cfg.home.ensureDirsExist;
        message = ''
          home.ensureDirsExist in impermanence must not contain paths starting with /home.
          These paths must be relative to the user's home directory.
        '';
      }
      {
        # Validate that userId matches the actual user's UID
        assertion = let
          userExists = config.users.users ? ${cfg.userName};
          actualUid = config.users.users.${cfg.userName}.uid or null;
        in
          !userExists || actualUid == null || actualUid == cfg.userId;
        message = ''
          Impermanence userId (${toString cfg.userId}) does not match the actual UID of user '${cfg.userName}'.

          The user '${cfg.userName}' has UID: ${toString (config.users.users.${cfg.userName}.uid or "not set")}
          But impermanence is configured with userId: ${toString cfg.userId}

          This mismatch will cause permission errors after boot.

          Fix by setting:
            atro.impermanence.userId = ${toString (config.users.users.${cfg.userName}.uid or 1000)};
        '';
      }
      {
        # Validate that groupId matches the actual user's primary group GID
        assertion = let
          userExists = config.users.users ? ${cfg.userName};
          actualGid =
            if userExists
            then let
              userGroup = config.users.users.${cfg.userName}.group or null;
              groupGid =
                if userGroup != null && config.users.groups ? ${userGroup}
                then config.users.groups.${userGroup}.gid or null
                else null;
            in
              groupGid
            else null;
        in
          !userExists || actualGid == null || actualGid == cfg.groupId;
        message = let
          userGroup = config.users.users.${cfg.userName}.group or "users";
          actualGid =
            if config.users.groups ? ${userGroup}
            then config.users.groups.${userGroup}.gid or null
            else null;
          gidDisplay =
            if actualGid != null
            then toString actualGid
            else "not set";
          suggestedGid =
            if actualGid != null
            then toString actualGid
            else "1000";
        in ''
          Impermanence groupId (${toString cfg.groupId}) does not match the actual GID of user '${cfg.userName}'.

          The user '${cfg.userName}' belongs to group '${userGroup}' with GID: ${gidDisplay}
          But impermanence is configured with groupId: ${toString cfg.groupId}

          This mismatch will cause permission errors after boot.

          Fix by setting:
            atro.impermanence.groupId = ${suggestedGid};
        '';
      }
    ];

    boot.initrd.postResumeCommands = lib.mkAfter initrdScript;

    sops.age.sshKeyPaths = [cfg.rootPrivateKeyPath];

    environment.persistence."/persistent" = {
      hideMounts = true;
      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/<user>/.ssh
      users.${cfg.userName} = {
        directories = cfg.home.dirs;
        files = cfg.home.files;
      };
      directories = cfg.global.dirs;
      # INFO: These dirs are not relative, must be full path.
      files = cfg.global.files;
    };
  };
}
