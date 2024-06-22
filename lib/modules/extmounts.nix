{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.extMounts;

  home_dir = {
    HOME = "/root";
  };
in {
  options.atro.extMounts = {
    enable = mkEnableOption "Mount external mounts when starting the system";
    includeK8sPods = mkOption {
      type = with types; bool;
      default = true;
      description = "Include k8s pods in the external mounts";
    };
    includeRzrMnt = mkOption {
      type = with types; bool;
      default = true;
      description = "Include rzr mnt in the external mounts";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.k8s-mount-pipelines = mkIf cfg.includeK8sPods {
      description = "Mount external mounts";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "tailscaled.service"];
      environment = home_dir;
      serviceConfig = {
        RemainAfterExit = "yes"; # systemd is stupid and will think the service is dead if it returns 0.
        ExecStart = "${pkgs.writeShellScript "k8s-mount-pipelines" ''
          SSH_KEY=/home/atropos/.ssh/id_ed25519
          REMOTE_USER=atropos
          REMOTE_HOST=pipelines
          REMOTE_DIR=/pvc
          LOCAL_DIR=/infra/k8s/pipelines

          mkdir -p $LOCAL_DIR
          if ${pkgs.util-linux}/bin/mountpoint -q $LOCAL_DIR; then
          	${pkgs.util-linux}/bin/umount $LOCAL_DIR
          fi

          ${pkgs.openssh}/bin/ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $REMOTE_USER@$REMOTE_HOST "sudo chown atropos:atropos $REMOTE_DIR && sudo chmod -R 777 $REMOTE_DIR"
          ${pkgs.sshfs-fuse}/bin/sshfs -o allow_other -o IdentityFile=$SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o uid=1000 -o gid=1000 $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR $LOCAL_DIR
        ''}";
        ExecStop = "${pkgs.writeShellScript "k8s-mount-pipelines-stop" ''
          ${pkgs.umount}/bin/umount  /infra/k8s/pipelines
        ''}";
        RestartSec = "30s";
        Restart = "always";
      };
    };

    systemd.services.k8s-mount-rzr-mnt = mkIf cfg.includeRzrMnt {
      description = "Mount external mounts - rzr mnt";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "tailscaled.service"];
      environment = home_dir;
      serviceConfig = {
        RemainAfterExit = "yes"; # systemd is stupid and will think the service is dead if it returns 0.
        ExecStart = "${pkgs.writeShellScript "k8s-mount-rzr-mnt" ''
          SSH_KEY=/root/.ssh/id_ed25519
          REMOTE_USER=root
          REMOTE_HOST=rzr
          REMOTE_DIR=/mnt
          LOCAL_DIR=/infra/rzr/mnt

          mkdir -p $LOCAL_DIR
          if ${pkgs.util-linux}/bin/mountpoint -q $LOCAL_DIR; then
          	${pkgs.util-linux}/bin/umount $LOCAL_DIR
          fi

          ${pkgs.sshfs-fuse}/bin/sshfs -o allow_other -o IdentityFile=$SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o uid=1000 -o gid=1000 $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR $LOCAL_DIR
        ''}";
        ExecStop = "${pkgs.writeShellScript "k8s-mount-rzr-mnt-stop" ''
          ${pkgs.util-linux}/bin/umount /infra/rzr/mnt
        ''}";
        RestartSec = "30s";
        Restart = "always";
      };
    };
  };
}
