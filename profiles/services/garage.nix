{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) hostName;
  shortHostName =
    if builtins.substring 0 4 hostName == "atro"
    then builtins.substring 4 (builtins.stringLength hostName) hostName
    else hostName;
in {
  atro = {
    garage = {
      enable = true;
      package = pkgs.garage_2;
      secrets = {
        rpcSecret = "garage/rpcSecret";
        adminToken = "garage/adminToken";
      };
      traceSink = "http://127.0.0.1:4317";
      rpcPublicAddr = "${shortHostName}:3901"; # Using tailscale address.
    };

    alloy.configs = [
      {
        priority = 100;
        value = ''
          prometheus.scrape "garage" {
            job_name = "garage"
            forward_to = [prometheus.relabel.default.receiver]
            scrape_interval = "15s"
            scrape_timeout = "10s"
            metrics_path    = "/metrics"
            scheme = "http"
            targets = [
              {"__address__" = "127.0.0.1:3903" },
            ]
          }
        '';
      }
    ];
  };
}
