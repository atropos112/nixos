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

  s3Endpoint = "rzr:9000";
  s3BucketName = "kopia";
  echo = "${pkgs.coreutils}/bin/echo";
  sleep = "${pkgs.coreutils}/bin/sleep";
  rg = "${pkgs.ripgrep}/bin/rg";
  kopia = "${pkgs.kopia}/bin/kopia";
  curl = "${pkgs.curl}/bin/curl";

  kopiaWebUICmd =
    if cfg.exposeWebUI
    then ''
      ${kopia} --log-level=debug server start --insecure --address="http://0.0.0.0:51515" --server-username=atropos --server-password="$KOPIA_GUI_PASSWORD" --disable-csrf-token-checks --metrics-listen-addr=0.0.0.0:8008
    ''
    else ''
      ${kopia} --log-level=debug server start --insecure --address="http://127.0.0.1:51515" --without-password --disable-csrf-token-checks --metrics-listen-addr=0.0.0.0:8008
    '';
  kopiaConnectCmd = ''${kopia} --log-level=debug repository connect s3 --bucket=${s3BucketName} --access-key="$KOPIA_KEY_ID" --secret-access-key="$KOPIA_KEY" --password="$KOPIA_PASSWORD" --endpoint="${s3Endpoint}" --disable-tls-verification --disable-tls'';
  kopiaCreateRepoCmd = ''
    ${kopia} --log-level=debug repository create s3 --bucket=${s3BucketName} --access-key="$KOPIA_KEY_ID" --secret-access-key="$KOPIA_KEY" --password="$KOPIA_PASSWORD" --endpoint="${s3Endpoint}" --disable-tls-verification --disable-tls
  '';

  ignorePaths = lib.forEach cfg.ignorePaths (path: ''--add-ignore="${path}"'');
  ignorePathsConcated = lib.concatMapStrings (x: " " + x) ignorePaths;
  kopiaSetupPolicyPrefix = ''${kopia} policy set ${cfg.path} --snapshot-time-crontab="0 */6 * * *" --compression="pgzip-best-compression" '';
  kopiaSetupPolicy = ''
    ${kopiaSetupPolicyPrefix} ${ignorePathsConcated}
  '';

  execCmd = "${pkgs.writeShellScript "kopiascript" ''
    # No -e as we expect some commands to fail (e.g. curl or kopiaConnectCmd)
    set -xu

    # Initialize variables
    KOPIA_KEY_ID=$(cat ${config.sops.secrets."kopia/rzr/keyId".path})
    KOPIA_KEY=$(cat ${config.sops.secrets."kopia/rzr/key".path})
    KOPIA_PASSWORD=$(cat ${config.sops.secrets."kopia/password".path})
    KOPIA_GUI_PASSWORD=$(cat ${config.sops.secrets."kopia/gui/password".path})
    KOPIA_CONFIG_PATH=$HOME/.config/kopia/repository.config

    # Wait for internet connection, by checking if we can reach a known website
    while ! ${curl} -s -f https://atro.xyz > /dev/null; do
      ${echo} "No internet connection, waiting 10 seconds..."
      ${sleep} 10
    done

    ${kopiaSetupPolicy}

    ${echo} "Internet connection established."}

    # Check if the repository is initialized and if not, initialize it
    connect_output=$(${kopiaConnectCmd} 2>&1)

    # From here on i expect no errors
    set -xeuo pipefail

    if ${echo} "$connect_output" | ${rg} -q "repository not initialized in the provided storage"; then
        ${kopiaCreateRepoCmd}
        ${sleep} 10 # For good measure
    fi


    # Connect to the repository again as sometimes the first connection fails
    ${kopiaConnectCmd}

    # Start the server
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
    path = mkOption {
      type = types.str;
    };
    ignorePaths = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "kopia/password" = {
        owner = cfg.runAs;
      };
      "kopia/rzr/keyId" = {
        owner = cfg.runAs;
      };
      "kopia/rzr/key" = {
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
