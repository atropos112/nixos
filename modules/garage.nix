{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf attrValues flatten elem;
  cfg = config.atro.garage;

  settings = {
    data_dir = [
      {
        capacity = cfg.data.capacity;
        path = cfg.data.dir; # Where data lives (need high capacity)
      }
    ];
    metadata_dir = cfg.metadataDir; # Where metadata lives (need high speed)
    db_engine = "lmdb"; # Database engine
    block_size = "10MiB"; # Size of each block
    use_local_tz = false;

    replication_factor = 2; # Number of copies of data

    rpc_bind_addr = "[::]:3901";
    rpc_public_addr = cfg.rpcPublicAddr;
    rpc_secret_file = config.sops.secrets."${cfg.secrets.rpcSecret}".path;

    s3_api = {
      s3_region = "us-east-1";
      api_bind_addr = "[::]:3900";
      root_domain = ".s3.garage.localhost";
    };
    s3_web = {
      bind_addr = "[::]:3902";
      index = "index.html";
      root_domain = ".web.garage.localhost";
    };

    k2v_api = {
      api_bind_addr = "[::]:3904";
    };

    admin = {
      api_bind_addr = "[::]:3903";
      admin_token_file = config.sops.secrets."${cfg.secrets.adminToken}".path;
      trace_sink = lib.mkIf (cfg.traceSink != null) cfg.traceSink;
      # Do not need token on metrics endpoint
      # metrics_token_file = "nope";
    };
  };
in {
  options.atro.garage = {
    enable = mkEnableOption "Enable Garage service";
    traceSink = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Trace sink for Garage service";
    };
    data = {
      dir = mkOption {
        type = types.str;
        description = "Directory where Garage stores its metadata";
      };
      capacity = mkOption {
        type = types.str;
        description = "Capacity of the Garage data directory";
      };
    };
    buckets = mkOption {
      type = types.listOf types.str;
      description = "List of buckets to create";
    };
    keys = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      description = "Keys and their associated buckets. Each key gets full access (read/write/owner) to its listed buckets.";
      example = {
        my_key_name = ["bucket1" "bucket2"];
        my_other_key = ["bucket2" "bucket3"];
      };
    };
    metadataDir = mkOption {
      type = types.str;
      description = "Directory where Garage stores its metadata";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.garage_2;
      description = "Garage package to use";
    };
    rpcPublicAddr = mkOption {
      type = types.str;
    };
    secrets = {
      rpcSecret = mkOption {
        type = types.str;
        description = "Path to the RPC secret file";
      };
      adminToken = mkOption {
        type = types.str;
        description = "Path to the admin token file";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        # buckets must not be empty
        assertion = cfg.buckets != [];
        message = "If Garage is enabled, at least one bucket must be specified in atro.garage.buckets";
      }
      {
        # keys must not be empty
        assertion = builtins.length (lib.attrsToList cfg.keys) > 0;
        message = "If Garage is enabled, at least one key must be specified in atro.garage.keys";
      }
      {
        assertion = let
          allKeyBuckets = cfg.keys |> attrValues |> flatten;
          invalidBuckets = builtins.filter (bucket: !(elem bucket cfg.buckets)) allKeyBuckets;
        in
          invalidBuckets == [];
        message = "All buckets referenced in keys must exist in the buckets list";
      }
    ];

    environment.systemPackages = [
      cfg.package
    ];

    systemd.services = {
      # SERVICE DEPENDENCY CHAIN:
      # 1. garage.service (main Garage daemon)
      # 2. garage-buckets.service (creates/manages S3 buckets)
      # 3. garage-keys.service (creates access keys and assigns bucket permissions)
      #
      # This order is critical because:
      # - Keys reference buckets, so buckets must exist first
      # - Both require Garage to be running and operational
      # - If any service fails, dependent services won't start

      garage-buckets = {
        description = "Create and manage Garage S3 buckets";

        # Systemd service dependencies:
        # - after: Start only after garage.service has started
        # - wants: If garage.service starts, this should start too (soft dependency)
        # - wantedBy: Auto-start this service when multi-user.target is reached
        after = ["garage.service"];
        wants = ["garage.service"];
        wantedBy = ["multi-user.target"];

        path = [cfg.package pkgs.gawk pkgs.coreutils];

        serviceConfig = {
          Type = "oneshot"; # Runs once and exits (not a daemon)
          RemainAfterExit = true; # Consider successful even after script exits
          User = "root";
          Group = "root";
        };

        script = ''
          garage status

          # Checking repeatedly with garage status until getting 0 exit code
          while ! garage status >/dev/null 2>&1; do
            echo "Garage not yet operational, waiting..."
            echo "Current garage status output:"
            garage status 2>&1 || true
            echo "---"
            sleep 5
          done

          # Now we check if garage status shows any failed nodes by checking for ==== FAILED NODES ====
          while garage status | grep -q "==== FAILED NODES ===="; do
            echo "Garage has failed nodes, waiting..."
            echo "Current garage status output:"
            garage status 2>&1 || true
            echo "---"
            sleep 5
          done

          echo "Garage is operational, proceeding with bucket management."

          # Get list of existing buckets
          existing_buckets=$(garage bucket list | tail -n +2 | awk '{print $3}' | grep -v '^$' || true)

          # Create buckets that should exist
          ${lib.concatMapStringsSep "\n" (bucket: ''
              if [[ "$(garage bucket info ${lib.escapeShellArg bucket} 2>&1 >/dev/null)" == *"Bucket not found"* ]]; then
                echo "Creating bucket ${lib.escapeShellArg bucket}"
                garage bucket create ${lib.escapeShellArg bucket}
              else
                echo "Bucket ${lib.escapeShellArg bucket} already exists"
              fi
            '')
            cfg.buckets}

          # Remove buckets that shouldn't exist
          for bucket in $existing_buckets; do
            should_exist=false
            ${lib.concatMapStringsSep "\n" (bucket: ''
              if [[ "$bucket" == ${lib.escapeShellArg bucket} ]]; then
                should_exist=true
              fi
            '')
            cfg.buckets}

            if [[ "$should_exist" == "false" ]]; then
              echo "Removing bucket $bucket"
              garage bucket delete --yes "$bucket"
            fi
          done
        '';
      };

      garage-keys = {
        description = "Create Garage access keys and configure bucket permissions";

        # Systemd service dependencies:
        # - after: Start only after garage-buckets.service completes
        # - wants: If garage-buckets starts, this should start too (soft dependency)
        # - requires: MUST have garage-buckets.service (hard dependency - won't start without it)
        # - wantedBy: Auto-start this service when multi-user.target is reached
        #
        # Why requires garage-buckets?
        # Access keys grant permissions to buckets. If buckets don't exist,
        # the permission assignment will fail. Therefore, buckets MUST be
        # created before keys can be configured.
        after = ["garage-buckets.service"];
        wants = ["garage-buckets.service"];
        requires = ["garage-buckets.service"];
        wantedBy = ["multi-user.target"];

        path = [cfg.package pkgs.gawk pkgs.coreutils];

        serviceConfig = {
          Type = "oneshot"; # Runs once and exits (not a daemon)
          RemainAfterExit = true; # Consider successful even after script exits
          User = "root";
          Group = "root";
        };

        script = ''
          garage key list
          echo "Managing keys..."

          # Get list of existing keys
          existing_keys=$(garage key list | tail -n +2 | awk '{print $3}' | grep -v '^$' || true)

          # Create keys that should exist
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (keyName: _: ''
              if [[ "$(garage key info ${lib.escapeShellArg keyName} 2>&1)" == *"Key not found"* ]]; then
                echo "Creating key ${lib.escapeShellArg keyName}"
                garage key create ${lib.escapeShellArg keyName}
              else
                echo "Key ${lib.escapeShellArg keyName} already exists"
              fi
            '')
            cfg.keys)}

          # Set up key permissions for buckets
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
              keyName: buckets:
                lib.concatMapStringsSep "\n" (bucket: ''
                  echo "Granting full access to key ${lib.escapeShellArg keyName} for bucket ${lib.escapeShellArg bucket}"
                  garage bucket allow --read --write --owner --key ${lib.escapeShellArg keyName} ${lib.escapeShellArg bucket}
                '')
                buckets
            )
            cfg.keys)}

          # Remove permissions from buckets that are no longer associated with keys
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (keyName: buckets: ''
              # Get current buckets this key has access to
              current_buckets=$(garage key info ${lib.escapeShellArg keyName} | grep -A 1000 "==== BUCKETS FOR THIS KEY ====" | tail -n +3 | awk '{print $3}' | grep -v '^$' || true)

              # Remove access from buckets not in the desired list
              for current_bucket in $current_buckets; do
                should_have_access=false
                ${lib.concatMapStringsSep "\n" (bucket: ''
                  if [[ "$current_bucket" == ${lib.escapeShellArg bucket} ]]; then
                    should_have_access=true
                  fi
                '')
                buckets}

                if [[ "$should_have_access" == "false" ]]; then
                  echo "Removing access for key ${lib.escapeShellArg keyName} from bucket $current_bucket"
                  garage bucket deny --key ${lib.escapeShellArg keyName} $current_bucket
                fi
              done
            '')
            cfg.keys)}

          # Remove keys that shouldn't exist
          for key in $existing_keys; do
            should_exist=false
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (keyName: _: ''
              if [[ "$key" == ${lib.escapeShellArg keyName} ]]; then
                should_exist=true
              fi
            '')
            cfg.keys)}

            if [[ "$should_exist" == "false" ]]; then
              echo "Removing key $key"
              garage key delete --yes "$key"
            fi
          done
        '';
      };
    };

    sops.secrets = {
      "${cfg.secrets.rpcSecret}" = {};
      "${cfg.secrets.adminToken}" = {};
    };
    # Can't use dynamic user with secrets above
    # because dynamic user is not allowed to read secrets
    systemd.services.garage.serviceConfig = {
      DynamicUser = false;
      ProtectHome = lib.mkForce false;
    };

    services.garage = {
      enable = true;
      inherit settings;
      inherit (cfg) package;
      # debug is nice but it's a bit too verbose
      logLevel = "info";
    };

    atro.fastfetch.modules = [
      {
        priority = 1006;
        value = {
          "type" = "command";
          "text" = "systemctl is-active garage";
          "key" = "Garage";
        };
      }
    ];
  };
}
