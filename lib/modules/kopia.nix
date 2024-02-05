{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.atro.kopia;

  # Must have HOME set for kopia to work
  home_dir = {
    HOME =
      if cfg.runAs == "root"
      then "/root"
      else "/home/" + cfg.runAs;
  };
  execCmd = "${pkgs.writeShellScript "kopia-script" ''
    KOPIA_KEY_ID=$(cat ${config.sops.secrets."kopia/linode/keyId".path})
    KOPIA_KEY=$(cat ${config.sops.secrets."kopia/linode/key".path})
    KOPIA_PASSWORD=$(cat ${config.sops.secrets."kopia/password".path})
    KOPIA_GUI_PASSWORD=$(cat ${config.sops.secrets."kopia/gui/password".path})
    KOPIA_CONFIG_PATH=$HOME/.config/kopia/repository.config

    ${pkgs.coreutils}/bin/echo "Generating config file if it doesn't exist..."
    ${pkgs.kopia}/bin/kopia --log-level=debug repository connect s3 --bucket=kopiabackup --access-key="$KOPIA_KEY_ID" --secret-access-key="$KOPIA_KEY" --password="$KOPIA_PASSWORD" --endpoint="eu-central-1.linodeobjects.com"
    ${pkgs.coreutils}/bin/echo "Starting Kopia server..."
    ${pkgs.kopia}/bin/kopia --log-level=debug server start --insecure --address="http://0.0.0.0:51515" --server-username=atropos --server-password="$KOPIA_GUI_PASSWORD" --disable-csrf-token-checks --metrics-listen-addr=0.0.0.0:8008
  ''}";
  kopiaService = {
    description = "Kopia server";
    after = ["network.target"];
    wantedBy = ["default.target"];
    environment = home_dir;
    serviceConfig = {
      ExecStart = execCmd;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
in {
  options.atro.kopia = {
    enable = mkEnableOption "kopia backup";
    runAs = mkOption {
      type = types.str;
      default = "atropos";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "kopia/password" = {
        owner = cfg.runAs;
      };
      "kopia/linode/keyId" = {
        owner = cfg.runAs;
      };
      "kopia/linode/key" = {
        owner = cfg.runAs;
      };
      "kopia/gui/password" = {
        owner = cfg.runAs;
      };
    };

    systemd.services.kopia-svc = mkIf (cfg.runAs
      == "root")
    kopiaService;

    systemd.user.services.kopia-svc = mkIf (cfg.runAs
      != "root")
    kopiaService;
  };
}
