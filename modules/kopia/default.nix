{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.atro.kopia;

  # Must have HOME set for kopia to work
  home_dir = {
    HOME =
      if cfg.runAs == "root"
      then "/root"
      else "/home/" + cfg.runAs;
  };

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

  kopiaConnectCmd = ''${kopia} --log-level=debug repository connect s3 --bucket=${cfg.s3.bucketName} --access-key="$KOPIA_ACCESS_KEY" --secret-access-key="$KOPIA_SECRET_ACCESS_KEY" --password="$KOPIA_PASSWORD" --endpoint="${cfg.s3.endpoint}" --disable-tls-verification --disable-tls'';

  kopiaCreateRepoCmd = ''
    ${kopia} --log-level=debug repository create s3 --bucket=${cfg.s3.bucketName} --access-key="$KOPIA_ACCESS_KEY" --secret-access-key="$KOPIA_SECRET_ACCESS_KEY" --password="$KOPIA_PASSWORD" --endpoint="${cfg.s3.endpoint}" --disable-tls-verification --disable-tls
  '';

  ignorePaths = lib.forEach cfg.ignorePaths (path: ''--add-ignore="${path}"'');
  ignorePathsConcated = lib.concatMapStrings (x: " " + x) ignorePaths;
  kopiaSetupPolicyPrefix = ''${kopia} policy set ${cfg.path} --snapshot-time-crontab="0 */6 * * *" --compression="pgzip-best-compression" '';
  kopiaSetupPolicy = ''
    ${kopiaSetupPolicyPrefix} ${ignorePathsConcated}
  '';

  # WARN: Adding secrets the way it is done is not a good idea, it means they are exposed to anyone with `systemctl status kopia access`
  # Ideally we would have kopia reading the secrets from a file but as far as I know that is not possible.
  execCmd = "${pkgs.writeShellScript "kopiascript" ''
    # No -e as we expect some commands to fail (e.g. curl or kopiaConnectCmd)
    set -xu

    # Initialize variables
    KOPIA_ACCESS_KEY=$(cat ${config.sops.secrets."${cfg.s3.accessKey}".path})
    KOPIA_SECRET_ACCESS_KEY=$(cat ${config.sops.secrets."${cfg.s3.secretAccessKey}".path})
    KOPIA_PASSWORD=$(cat ${config.sops.secrets."${cfg.password}".path})
    KOPIA_GUI_PASSWORD=$(cat ${config.sops.secrets."${cfg.guiPassword}".path})

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

    s3 = {
      endpoint = mkOption {
        type = types.str;
      };
      bucketName = mkOption {
        type = types.str;
      };

      accessKey = mkOption {
        type = types.str;
        description = "The access key location in sops nix.";
      };

      secretAccessKey = mkOption {
        type = types.str;
        description = "The secret access key location in sops nix.";
      };
    };

    password = mkOption {
      type = types.str;
      description = "A password location for the kopia repository in sops nix.";
    };

    guiPassword = mkOption {
      type = types.str;
      description = "A password location for the kopia gui in sops nix.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "${cfg.password}" = {
        owner = cfg.runAs;
      };
      "${cfg.guiPassword}" = {
        owner = cfg.runAs;
      };
      "${cfg.s3.accessKey}" = {
        owner = cfg.runAs;
      };
      "${cfg.s3.secretAccessKey}" = {
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
