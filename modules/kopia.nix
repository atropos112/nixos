{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf map concatMapStrings;
  cfg = config.atro.kopia;

  # Must have HOME set for kopia to work
  home_dir = {
    HOME =
      if cfg.runAs == "root"
      then "/root"
      else "/home/" + cfg.runAs;
  };

  beforeSnapshotScript = pkgs.writeShellApplication {
    name = "kopia-before-snapshot";
    runtimeInputs = with pkgs; [networkmanager coreutils];
    text = ''
      INTERFACE="${cfg.networkInterface}"
      if [ -z "$INTERFACE" ]; then
        # No interface specified, always proceed
        exit 0
      fi

      # IS_METERED will be "yes", "no" or "unknown"
      IS_METERED=$(nmcli -t -f GENERAL.METERED dev show "$INTERFACE" | cut -d: -f2 | cut -d' ' -f1)

      if [ "$IS_METERED" = "yes" ]; then
        echo "On a metered connection, skipping backup"
        exit 1
      fi

      echo "Not on a metered connection, proceeding with backup"
      exit 0
    '';
  };

  # Kopia WebUI command - uses KOPIA_GUI_PASSWORD from environment (set by systemd)
  kopiaWebUICmd =
    if cfg.exposeWebUI
    then ''
      kopia \
        --log-level=debug \
        server start \
        --insecure \
        --address="http://0.0.0.0:51515" \
        --server-username=atropos \
        --server-password="$KOPIA_GUI_PASSWORD" \
        --disable-csrf-token-checks \
        --metrics-listen-addr=0.0.0.0:8008
    ''
    else ''
      kopia \
        --log-level=debug \
        server start \
        --insecure \
        --address="http://127.0.0.1:51515" \
        --without-password \
        --disable-csrf-token-checks \
        --metrics-listen-addr=0.0.0.0:8008
    '';

  # Kopia connect command - uses AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and KOPIA_PASSWORD from environment
  # No need to pass secrets on command line - Kopia reads them from environment variables automatically
  kopiaConnectCmd = "kopia --log-level=debug repository connect s3 --bucket=${cfg.s3.bucketName} --endpoint=${cfg.s3.endpoint} --disable-tls-verification --disable-tls";

  # Kopia create repository command - uses environment variables for credentials
  kopiaCreateRepoCmd = "kopia --log-level=debug repository create s3 --bucket=${cfg.s3.bucketName} --endpoint=${cfg.s3.endpoint} --disable-tls-verification --disable-tls";

  ignorePaths = paths:
    paths
    |> map (path: ''--add-ignore="${path}"'')
    |> concatMapStrings (p: " " + p);

  kopiaSetupPolicies = backups:
    backups
    |> map (backup:
      ''
        kopia \
          policy set "${backup.path}" \
          --snapshot-time-crontab="${backup.cron}" \
          --before-folder-action="${beforeSnapshotScript}/bin/kopia-before-snapshot" \
          --compression="pgzip-best-compression" \
      ''
      + (ignorePaths backup.ignores))
    |> concatMapStrings (p: "\n" + p);

  # Kopia script - secrets are loaded via systemd EnvironmentFile (see serviceConfig below)
  # Kopia automatically reads AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, KOPIA_PASSWORD from environment
  kopiaScript = pkgs.writeShellApplication {
    name = "kopia-service";
    runtimeInputs = with pkgs; [kopia curl coreutils gnused ripgrep];
    text = ''
      # No -e as we expect some commands to fail (e.g. curl or kopiaConnectCmd)
      set +e
      set -xu

      # Secrets are already loaded by systemd via EnvironmentFile
      # They're available as: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, KOPIA_PASSWORD, KOPIA_GUI_PASSWORD
      # No need to read them from files here - they're in the environment

      # Wait for internet connection, by checking if we can reach a known website
      while ! curl -s -f https://atro.xyz > /dev/null; do
        echo "No internet connection, waiting 10 seconds..."
        sleep 10
      done

      echo "Internet connection established."

      # Validate S3 endpoint is reachable before attempting to connect
      echo "Validating S3 endpoint accessibility..."
      s3_endpoint="${cfg.s3.endpoint}"

      # Extract host from endpoint (remove http:// or https:// prefix if present)
      s3_host=$(echo "$s3_endpoint" | sed 's|^https\?://||' | cut -d: -f1)

      # Try to reach the S3 endpoint (allow up to 10 seconds for the connection)
      if ! curl -s -f --max-time 10 "$s3_endpoint" > /dev/null 2>&1; then
        echo "================================================================"
        echo "WARNING: S3 endpoint may not be accessible"
        echo "================================================================"
        echo ""
        echo "Could not reach S3 endpoint: $s3_endpoint"
        echo ""
        echo "This might be normal if the endpoint requires authentication,"
        echo "but if Kopia fails to connect, troubleshoot with these steps:"
        echo ""
        echo "  1. Verify endpoint is correct: $s3_endpoint"
        echo "  2. Check if S3 service is running"
        echo "  3. Verify network connectivity: ping $s3_host"
        echo "  4. Check firewall rules allow access to S3 ports"
        echo "  5. If using Garage, check: systemctl status garage"
        echo ""
        echo "Continuing with Kopia connection attempt..."
        echo "================================================================"
      else
        echo "S3 endpoint is reachable at: $s3_endpoint"
      fi

      ${kopiaSetupPolicies cfg.backups}

      # Check if the repository is initialized and if not, initialize it
      connect_output=$(${kopiaConnectCmd} 2>&1 || true)

      # From here on i expect no errors
      set -euo pipefail

      if echo "$connect_output" | rg -q "repository not initialized in the provided storage"; then
          echo "Repository not initialized, creating..."
          ${kopiaCreateRepoCmd}
          sleep 10 # For good measure
      fi

      # Connect to the repository again as sometimes the first connection fails
      ${kopiaConnectCmd}

      # Start the server
      ${kopiaWebUICmd}
    '';
  };

  kopiaService = {
    description = "Kopia backup service";
    after = ["network.target" "graphical.target"];
    wantedBy = ["default.target"];
    environment = home_dir;
    serviceConfig = {
      ExecStart = "${kopiaScript}/bin/kopia-service";
      Restart = "on-failure";
      RestartSec = "5s";

      # SECURITY: Load secrets from environment file managed by sops-nix
      # This prevents secrets from being visible in process arguments or systemctl status
      EnvironmentFile = config.sops.templates."kopia-env".path;

      # SECURITY: Prevent other users from inspecting this process
      ProtectProc = "invisible"; # Hide /proc/[pid]/ from other users
      ProcSubset = "pid"; # Only show PIDs in /proc, not detailed process info

      # Additional hardening
      PrivateTmp = true; # Give service its own /tmp
      NoNewPrivileges = true; # Prevent privilege escalation

      # Note: ProtectSystem = "strict" would make /root read-only, breaking Kopia
      # Kopia needs to write to /root/.config and /root/.cache (when running as root)
      # or /home/<user>/.config and /home/<user>/.cache (when running as user)
      # Instead, we allow it but use other protections
      ProtectSystem = "full"; # Make /usr, /boot, /efi read-only (but not /root or /home)

      # Kopia needs to access backup paths in home directories regardless of which user runs it
      ProtectHome = false;
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
    networkInterface = mkOption {
      type = types.str;
      default = "";
      description = "The network interface to check for metered connection";
    };
    backups = mkOption {
      type = types.listOf (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Path to backup";
            example = "/home/user/documents";
          };

          ignores = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of patterns to ignore";
            example = ["*.tmp" "*.log" ".cache/*"];
          };

          cron = mkOption {
            type = types.str;
            description = "Cron schedule for the backup";
            example = "0 2 * * *";
            default = "0 */6 * * *"; # Default to every 6 hours
          };
        };
      });
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

    # Create environment file template with all secrets for Kopia to use
    # This file will be at /run/secrets-rendered/kopia-env and contain the actual secret values
    sops.templates."kopia-env" = {
      owner = cfg.runAs;
      mode = "0400"; # Read-only for owner only
      content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."${cfg.s3.accessKey}"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."${cfg.s3.secretAccessKey}"}
        KOPIA_PASSWORD=${config.sops.placeholder."${cfg.password}"}
        KOPIA_GUI_PASSWORD=${config.sops.placeholder."${cfg.guiPassword}"}
      '';
    };

    atro.fastfetch.modules = [
      {
        priority = 1004;
        value = {
          "type" = "command";
          "text" = "systemctl is-active kopia";
          "key" = "Kopia";
        };
      }
    ];

    systemd.services.kopia = mkIf (cfg.runAs
      == "root")
    kopiaService;

    systemd.user.services.kopia = mkIf (cfg.runAs
      != "root")
    kopiaService;
  };
}
