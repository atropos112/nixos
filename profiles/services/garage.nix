{
  pkgs,
  config,
  ...
}: {
  atro = {
    garage = {
      enable = true;
      package = pkgs.garage_2;
      secrets = {
        rpcSecret = "garage/rpcSecret";
        adminToken = "garage/adminToken";
      };
      traceSink = "http://127.0.0.1:4317";
      rpcPublicAddr = "${config.networking.hostName}:3901"; # Using tailscale address.
      keys = {
        k8s = [
          "loki-chunks"
          "loki-admin"
          "loki-ruler"
          "psql"
          "attic" # to be removed
          "atticd"
          "awf"
          "pyroscope"
          "tempo"
          "longhorn"
          "synapse"
          "influxdb"
        ];
        nixos = [
          "kopia"
        ];
      };
      buckets = [
        "loki-chunks"
        "loki-admin"
        "loki-ruler"
        "psql"
        "attic" # to be removed
        "atticd"
        "kopia"
        "awf"
        "pyroscope"
        "tempo"
        "longhorn"
        "synapse"
        "influxdb"
      ];
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
