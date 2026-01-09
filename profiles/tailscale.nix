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

  # Enable all three tailscale monitoring components
  atro = {
    tailscale-watchdog.enable = true;

    tailscale-exporter.enable = true;

    tailscale-native-metrics.enable = true;

    # Add Alloy config to scrape textfile metrics from /var/lib/alloy/*.prom
    # This scrapes metrics from all three components:
    # - tailscale-watchdog.prom (state machine metrics)
    # - tailscale-peers.prom (per-peer metrics from status --json)
    # - tailscale-native.prom (native tailscale metrics print output)
    alloy.configs = [
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
  };
}
