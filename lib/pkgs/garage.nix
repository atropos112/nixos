{
  config,
  pkgs,
  lib,
  ...
}: let
  garage = pkgs.garage_2;
  settings = {
    data_dir = [
      {
        capacity = "2T";
        path = "/mnt/garage"; # Where data lives (need high capacity)
      }
    ];
    metadata_dir = "/home/atropos/garage_metadata"; # Where metadata lives (need high speed)
    db_engine = "sqlite"; # Database engine

    replication_factor = 1; # Number of copies of data

    rpc_bind_addr = "[::]:3901";
    rpc_public_addr = "127.0.0.1:3901";
    rpc_secret_file = config.sops.secrets."garage/rpcSecret".path;

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
      admin_token_file = config.sops.secrets."garage/adminToken".path;
      # Do not need token on metrics endpoint
      # metrics_token_file = "nope";
    };
  };
in {
  environment.systemPackages = [
    garage
  ];

  sops.secrets = {
    "garage/rpcSecret" = {};
    "garage/adminToken" = {};
  };
  # Can't use dynamic user with secrets above
  # because dynamic user is not allowed to read secrets
  systemd.services.garage.serviceConfig = {
    DynamicUser = false;
    ProtectHome = lib.mkForce false;
  };

  services.garage = {
    enable = true;
    extraEnvironment = {
      RUST_BACKTRACE = "yes";
    };
    inherit settings;
    package = garage;
    logLevel = "debug";
  };
}
