{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
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
        # If cfg.enable is true, cfg.buckets must not be empty
        assertion = cfg.enable -> (cfg.buckets != []);
        message = "If Garage is enabled, at least one bucket must be specified in atro.garage.buckets";
      }
    ];

    environment.systemPackages = [
      cfg.package
    ];

    systemd.services.garage-buckets = {
      description = "Create Garage buckets";
      after = ["garage.service"];
      wants = ["garage.service"];
      wantedBy = ["multi-user.target"];

      path = [cfg.package pkgs.gawk pkgs.coreutils];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
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
            # garage bucket delete --yes "$bucket"
          fi
        done
      '';
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
      package = cfg.package;
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
