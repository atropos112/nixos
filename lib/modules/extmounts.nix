{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.extMounts;

  sshfsOpts = [
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
    options = sshfsOpts;
  };
in {
  options.atro.extMounts = {
    enable = mkEnableOption "Mount external mounts when starting the system";
  };

  config = mkIf cfg.enable {
    fileSystems = {
      "/infra/k8s/pipelines" = mkSshFs "atropos@9.1.0.23:/pvc/";
      "/infra/k8s/backups" = mkSshFs "atropos@9.1.0.23:/backups/";
      "/infra/rzr/mnt" = mkSshFs "atropos@rzr:/mnt/";
    };
  };
}
