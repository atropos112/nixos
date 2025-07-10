{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf mapAttrs;
  cfg = config.atro.externalMounts;

  defaultSSHfsOpts = [
    "allow_other" # for non-root access
    "_netdev" # this is a network fs
    "x-systemd.automount" # mount on demand
    "noauto" # don't mount on boot

    # SSH options
    "reconnect" # handle connection drops
    "ServerAliveInterval=15" # keep connections alive
    "IdentityFile=/home/atropos/.ssh/id_ed25519"
    "StrictHostKeyChecking=no"
    "UserKnownHostsFile=/dev/null"
    "uid=1000"
    "gid=1000"
  ];

  mkSshFs = device: {
    inherit device;
    fsType = "sshfs";
    options = cfg.sshfsOpts;
  };
in {
  options.atro.externalMounts = {
    enable = mkEnableOption "Mount external mounts when starting the system";
    sshfsOpts = mkOption {
      type = types.listOf types.str;
      default = defaultSSHfsOpts;
      description = "Options to pass to sshfs";
    };
    mounts = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        External mounts, key is the mount point, value is the SSH external mount.
        Example:
        {
          "/mnt/backups" = "atropos@backups:/mnt/";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    fileSystems = mapAttrs (_: mkSshFs) cfg.mounts;
  };
}
