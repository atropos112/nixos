/*
Impermanence implementation for sopsnix based ZFS wiping impermanenece.

It assumes
- one normal user + root,
- the persistent directory is mounted at /persistent
- your zfs setup has zroot/nixos/root@blank and zroot/nixos/home@blank
- uuid and guid are set to 1000 and 1000 respectively
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
    chown -R 1000:1000 /home/atropos

    mkdir -p /persistent/home/atropos
    HOME_OWNER=$(stat -c '%u' "/persistent/home/atropos") # Optimising, only chown if the whole dir is not belonging to the user.
    if [ "$HOME_OWNER" -ne "1000" ]; then
     echo "Fixing permissions for persistent..."
     chown -R 1000:1000 /persistent/home/atropos
    fi

    echo "Unmounting home..."
    umount /home

    echo "Unmounting persistent..."
    umount /persistent

    echo "Permissions fixed."
    echo "--------------------------------------------------"
  '';
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
    global = {
      dirs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          List of global directories to map.

          For example
          ["/root/.ssh", "/var/lib/bluetooth"] would map /persistent/root/.ssh and /persistent/var/lib/bluetooth to
          /root/.ssh and /var/lib/bluetooth respectively.
        '';
      };
      files = mkOption {
        type = types.listOf types.str;
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
        type = types.listOf types.str;
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

          Do note some directories will always be crreated, such as .config, .local, .cache, .ssh and .local/share.
          This is necessary as otherwise these directories would be made by root:root and not allow the user to login.
        '';
      };
      files = mkOption {
        type = types.listOf types.str;
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
