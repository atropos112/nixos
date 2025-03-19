{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
in {
  sops.secrets = {
    "syncthing/${hostName}/cert" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
      mode = "0600";
    };
    "syncthing/${hostName}/key" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
      mode = "0600";
    };
  };

  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    # Run syncthing first time without the keys, they will appear in .config/syncthing then copy them over and then enable the below to keep them "forever"
    cert = config.sops.secrets."syncthing/${hostName}/cert".path;
    key = config.sops.secrets."syncthing/${hostName}/key".path;
    overrideDevices = true;
    overrideFolders = true;
    configDir = "/home/atropos/.config/syncthing";
    user = "atropos";
    systemService = true;
    guiAddress = "0.0.0.0:8384";
    settings = {
      gui = {
        theme = "black";
        password = "$2y$12$8NqZv2uGypWM9AfQRoklbeEMZ2wmtPlSdkCu4tkE73VkiYzAXHdg2"; # bcrypt hash of the real password which is in BitWarden
        user = "atropos";
        insecureSkipHostcheck = true;
      };
      options = {
        urAccepted = -1;
      };
      devices = {
        cluster = {
          addresses = [
            "tcp://syncthing"
          ];
          autoAcceptFolders = false; # Can't auto accept as those will be overridden by the config below
          id = "ZLCZ4HZ-E67BWUS-5VLRQ5M-PIA4JJW-DMBVDZH-EMOF5AM-S5R6QE7-IMXBEA2";
        };
      };
      folders = {
        sync = {
          enable = true;
          id = "ezaua-zrnnt";
          devices = ["cluster"];
          path = "/home/atropos/Sync";
        };
      };
    };
  };
}
