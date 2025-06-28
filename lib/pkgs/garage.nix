{
  config,
  pkgs,
  ...
}: let
  garage = pkgs.garage_2;
  toml = pkgs.formats.toml {};
  settings = {
    data_dir = "/mnt/garage"; # Where data lives (need high capacity)
    metadata_dir = "/home/atropos/garage_metadata"; # Where metadata lives (need high speed)
    db_engine = "sqlite"; # Database engine

    replication_factor = 1; # Number of copies of data

    rpc_bind_addr = "[::]:3901";
    rpc_public_addr = "127.0.0.1:3901";
    # TODO:
    rpc_secret = "3fb2b60d803f1c7d8e459116b51a8a0f21346dd1b480225f277688d5185231ee";
    rpc_secret_file = config.sops.secrets."garage/rpcSecret".path;

    s3_api = {
      s3_region = "us-east-1";
      api_bind_addr = "[::]:3900";
    };
    s3_web = {
      bind_addr = "[::]:3902";
      index = "index.html";
    };

    k2v_api = {
      api_bind_addr = "[::]:3904";
    };

    admin = {
      api_bind_addr = "[::]:3903";
      admin_token = "admin";
      admin_token_file = config.sops.secrets."garage/adminToken".path;
      # Do not need token on metrics endpoint
      # metrics_token_file = "nope";
    };
  };
  # Need it as a file for arion and as nix-config for garage
  configFile = toml.generate "garage.toml" settings;
in {
  environment.systemPackages = [
    garage
  ];

  sops.secrets = {
    "garage/rpcSecret" = {};
    "garage/adminToken" = {};
  };

  virtualisation.arion = {
    backend = "docker";
    projects = {
      "garage".settings.services."garage_ui".service = {
        image = "dxflrs/garage:v1.0.1";
        restart = "unless-stopped";
        ports = ["3909:3909"];
        volumes = [
          "${configFile}:/etc/garage/garage.toml"
        ];
        environment = {
          API_BASE_URL = "http://localhost:3903";
          S3_ENDPOINT_URL = "http://localhost:3900";
        };
      };
    };
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
