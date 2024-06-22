{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.extMounts;
in {
  options.atro.extMounts = {
    enable = mkEnableOption "Mount external mounts when starting the system";
    includeK8sPods = mkOption {
      type = with types; bool;
      default = cfg.enable;
      description = "Include k8s pods in the external mounts";
    };
    includeRzrMnt = mkOption {
      type = with types; bool;
      default = cfg.enable;
      description = "Include rzr mnt in the external mounts";
    };
  };

  config = mkIf.cfg.enable {
    systemd.services.k8s-nodes-mount = {
      description = "Mount external mounts";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "tailscaled.service"];
      serviceConfig = {
        ExecStart = "${pkgs.writeShellScript "k8s-nodes-mount-start" ''
          mkdir -p /infra/k8s/pipelines
          sshfs -o allow_other,IdentityFile=/home/atropos/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=15 -o ServerAliveCountMax=3 atropos@pipelines /infra/k8s/pipelines
        ''}";
        ExecStop = "${pkgs.writeShellScript "k8s-nodes-mount-stop" ''
          umount /infra/k8s/pipelines
        ''}";
        RestartSec = "30s";
        Restart = "always";
      };
    };
  };
}
