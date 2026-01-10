{
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/key".path;
    package = pkgs.tailscale;
    extraUpFlags = [
      "--hostname=${config.networking.hostName}"
      "--accept-dns=false" # This is done manually in the networking/dns.nix
    ];
  };

  # Enable tailscale monitoring and maintenance components
  atro.tailscale = {
    exporter.enable = true;
    native-metrics.enable = true;
    keepalive.enable = true;
    watchdog = {
      enable = true;
      # orth is behind CGNAT (LilaConnect ISP) and can only use relay
      excludePeers = ["orth"];
    };
  };

  # Add Alloy config to scrape textfile metrics from /var/lib/alloy/*.prom
  # - tailscale-peers.prom (per-peer metrics from status --json)
  # - tailscale-native.prom (native tailscale metrics print output)
  # - tailscale-watchdog.prom (watchdog state and counters)
  atro.alloy.configs = [
    {
      priority = 102; # After syncthing (101) but still early
      value = ''
        // Tailscale textfile metrics collector
        prometheus.exporter.unix "tailscale_textfile" {
          enable_collectors = ["textfile"]
          textfile {
            directory = "/var/lib/alloy"
          }
        }

        prometheus.scrape "tailscale_textfile" {
          job_name        = "tailscale"
          forward_to      = [prometheus.relabel.default.receiver]
          targets         = prometheus.exporter.unix.tailscale_textfile.targets
          scrape_interval = "15s"
          scrape_timeout  = "10s"
        }
      '';
    }
  ];
}
