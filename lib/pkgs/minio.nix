{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    minio-client
  ];
  sops.secrets = {
    "minio/rootCredentials" = {};
  };

  services = {
    minio = {
      enable = true;
      package = pkgs.minio;
      dataDir = [
        "/mnt/minio"
      ];
      consoleAddress = ":9001";
      listenAddress = ":9000";
      region = "us-east-1";
      browser = true; # Enable browser
      rootCredentialsFile = config.sops.secrets."minio/rootCredentials".path;
    };
  };
}
