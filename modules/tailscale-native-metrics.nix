{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.atro.tailscale-native-metrics;
  inherit (lib) mkEnableOption mkOption mkIf types;

  # ============================================================================
  # Native Tailscale metrics exporter
  # Runs `tailscale metrics print` and writes to a .prom file for scraping
  # ============================================================================
  nativeMetricsScript = pkgs.writeShellApplication {
    name = "tailscale-native-metrics";
    runtimeInputs = with pkgs; [tailscale coreutils];
    text = ''
      set -euo pipefail

      METRICS_FILE="''${TAILSCALE_NATIVE_METRICS_FILE:-/var/lib/alloy/tailscale-native.prom}"
      mkdir -p "$(dirname "$METRICS_FILE")"

      METRICS_TMP=$(mktemp)
      trap 'rm -f "$METRICS_TMP"' EXIT

      # Get native metrics from tailscale
      if tailscale metrics print > "$METRICS_TMP" 2>/dev/null; then
        chmod 644 "$METRICS_TMP"
        mv "$METRICS_TMP" "$METRICS_FILE"
      else
        # If metrics command fails, write a down indicator
        {
          echo "# Tailscale native metrics unavailable"
          echo "tailscale_native_metrics_up 0"
        } > "$METRICS_FILE"
        chmod 644 "$METRICS_FILE"
      fi
    '';
  };
in {
  options.atro.tailscale-native-metrics = {
    enable = mkEnableOption "Native Tailscale metrics via `tailscale metrics print`";

    interval = mkOption {
      type = types.str;
      default = "15s";
      description = "How often to collect native metrics";
    };

    metricsPath = mkOption {
      type = types.str;
      default = "/var/lib/alloy/tailscale-native.prom";
      description = "Path to write native Tailscale metrics";
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d ${builtins.dirOf cfg.metricsPath} 0755 root root -"
      ];

      services.tailscale-native-metrics = {
        description = "Native Tailscale metrics exporter";
        after = ["tailscaled.service"];
        wants = ["tailscaled.service"];

        environment = {
          TAILSCALE_NATIVE_METRICS_FILE = cfg.metricsPath;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${nativeMetricsScript}/bin/tailscale-native-metrics";
          ProtectSystem = "strict";
          PrivateTmp = true;
          ReadWritePaths = [(builtins.dirOf cfg.metricsPath)];
        };
      };

      timers.tailscale-native-metrics = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "15s";
          OnUnitActiveSec = cfg.interval;
          RandomizedDelaySec = "3s";
        };
      };
    };
  };
}
