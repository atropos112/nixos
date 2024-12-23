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

  s3Endpoint = "opiz2:9000";
  s3BucketName = "kopiabackup";

  kopiaWebUICmd =
    if cfg.exposeWebUI
    then ''
      ${pkgs.kopia}/bin/kopia --log-level=debug server start --insecure --address="http://0.0.0.0:51515" --server-username=atropos --server-password="$KOPIA_GUI_PASSWORD" --disable-csrf-token-checks --metrics-listen-addr=0.0.0.0:8008
    ''
    else ''
      ${pkgs.kopia}/bin/kopia --log-level=debug server start --insecure --address="http://127.0.0.1:51515" --without-password --disable-csrf-token-checks --metrics-listen-addr=0.0.0.0:8008
    '';
  kopiaConnectCmd = ''${pkgs.kopia}/bin/kopia --log-level=debug repository connect s3 --bucket=${s3BucketName} --access-key="$KOPIA_KEY_ID" --secret-access-key="$KOPIA_KEY" --password="$KOPIA_PASSWORD" --endpoint="${s3Endpoint}" --disable-tls-verification --disable-tls'';
  kopiaCreateRepoCmd = ''${pkgs.kopia}/bin/kopia --log-level=debug repository create s3 --bucket=${s3BucketName} --access-key="$KOPIA_KEY_ID" --secret-access-key="$KOPIA_KEY" --password="$KOPIA_PASSWORD" --endpoint="${s3Endpoint}" --disable-tls-verification --disable-tls'';

  execCmd = "${pkgs.writeShellScript "kopiascript" ''
    set -xeu

       ${pkgs.coreutils}/bin/sleep 300 # Bit hacky...
       KOPIA_KEY_ID=$(cat ${config.sops.secrets."kopia/opiz2/keyId".path})
       KOPIA_KEY=$(cat ${config.sops.secrets."kopia/opiz2/key".path})
       KOPIA_PASSWORD=$(cat ${config.sops.secrets."kopia/password".path})
       KOPIA_GUI_PASSWORD=$(cat ${config.sops.secrets."kopia/gui/password".path})
       KOPIA_CONFIG_PATH=$HOME/.config/kopia/repository.config


       connect_output=$(${kopiaConnectCmd} 2>&1)

       if [[ "$connect_output" == *"repository not initialized in the provided storage"* ]]; then
           ${kopiaCreateRepoCmd}
       	${pkgs.coreutils}/bin/echo "Sleeping for 10 seconds for good measure."
       fi


       ${pkgs.coreutils}/bin/sleep 10 # Bit hacky...
       # Connect to the repository again as sometimes the first connection fails
       ${kopiaConnectCmd}

       ${pkgs.coreutils}/bin/echo "Generating config file if it doesn't exist..."
       ${pkgs.coreutils}/bin/echo "Starting Kopia server..."
       ${kopiaWebUICmd}
  ''}";

  kopiaService = {
    description = "Kopia server";
    after = ["network.target" "graphical.target"];
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

    exposeWebUI = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "kopia/password" = {
        owner = cfg.runAs;
      };
      "kopia/opiz2/keyId" = {
        owner = cfg.runAs;
      };
      "kopia/opiz2/key" = {
        owner = cfg.runAs;
      };
      "kopia/gui/password" = {
        owner = cfg.runAs;
      };
    };

    systemd.services.kopia = mkIf (cfg.runAs
      == "root")
    kopiaService;

    systemd.user.services.kopia = mkIf (cfg.runAs
      != "root")
    kopiaService;
  };
}
