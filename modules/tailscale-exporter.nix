{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.atro.tailscale-exporter;
  inherit (lib) mkEnableOption mkOption mkIf types;

  # ============================================================================
  # Per-peer metrics exporter from tailscale status --json
  # Complements native metrics which are aggregate-only
  # ============================================================================
  exporterScript = pkgs.writeShellApplication {
    name = "tailscale-exporter";
    runtimeInputs = with pkgs; [tailscale jq coreutils];
    text = ''
      set -euo pipefail

      METRICS_FILE="''${TAILSCALE_EXPORTER_METRICS_FILE:-/var/lib/alloy/tailscale-peers.prom}"
      mkdir -p "$(dirname "$METRICS_FILE")"

      METRICS_TMP=$(mktemp)
      trap 'rm -f "$METRICS_TMP"' EXIT

      # Get status JSON
      STATUS=$(tailscale status --json 2>/dev/null || echo '{}')
      SELF_HOSTNAME=$(echo "$STATUS" | jq -r '.Self.HostName // "unknown"')
      NOW=$(date +%s)

      # ========== Self/Node metrics ==========
      cat >> "$METRICS_TMP" << 'HEADER'
      # HELP tailscale_up Whether tailscale is running (1=Running, 0=other)
      # TYPE tailscale_up gauge
      # HELP tailscale_health_issues Number of health issues reported
      # TYPE tailscale_health_issues gauge
      # HELP tailscale_version_info Tailscale version information
      # TYPE tailscale_version_info gauge
      # HELP tailscale_exporter_last_scrape_timestamp_seconds Unix timestamp of last scrape
      # TYPE tailscale_exporter_last_scrape_timestamp_seconds gauge
      HEADER

      BACKEND_STATE=$(echo "$STATUS" | jq -r '.BackendState // "Unknown"')
      VERSION=$(echo "$STATUS" | jq -r '.Version // "unknown"')
      HEALTH_ISSUES=$(echo "$STATUS" | jq '.Health | length // 0')

      {
        if [[ "$BACKEND_STATE" == "Running" ]]; then
          echo "tailscale_up 1"
        else
          echo "tailscale_up 0"
        fi
        echo "tailscale_version_info{version=\"$VERSION\",hostname=\"$SELF_HOSTNAME\"} 1"
        echo "tailscale_health_issues $HEALTH_ISSUES"
        echo "tailscale_exporter_last_scrape_timestamp_seconds $NOW"
      } >> "$METRICS_TMP"

      # ========== Peer metrics ==========
      cat >> "$METRICS_TMP" << 'HEADER'
      # HELP tailscale_peer_online Whether peer is online (1) or offline (0)
      # TYPE tailscale_peer_online gauge
      # HELP tailscale_peer_direct Whether peer has direct connection (1) or relay (0)
      # TYPE tailscale_peer_direct gauge
      # HELP tailscale_peer_active Whether peer has active traffic (1) or idle (0)
      # TYPE tailscale_peer_active gauge
      # HELP tailscale_peer_exit_node Whether peer is current exit node (1) or not (0)
      # TYPE tailscale_peer_exit_node gauge
      # HELP tailscale_peer_rx_bytes_total Bytes received from peer
      # TYPE tailscale_peer_rx_bytes_total counter
      # HELP tailscale_peer_tx_bytes_total Bytes transmitted to peer
      # TYPE tailscale_peer_tx_bytes_total counter
      # HELP tailscale_peer_last_handshake_seconds_ago Seconds since last WireGuard handshake
      # TYPE tailscale_peer_last_handshake_seconds_ago gauge
      # HELP tailscale_peer_info Peer metadata labels
      # TYPE tailscale_peer_info gauge
      HEADER

      echo "$STATUS" | jq -r '.Peer // {} | to_entries[] | @json' | while read -r peer_json; do
        PEER=$(echo "$peer_json" | jq -r '.value')
        HOSTNAME=$(echo "$PEER" | jq -r '.HostName // "unknown"')
        OS=$(echo "$PEER" | jq -r '.OS // "unknown"')
        RELAY=$(echo "$PEER" | jq -r '.Relay // ""')
        CURADDR=$(echo "$PEER" | jq -r '.CurAddr // ""')
        ONLINE=$(echo "$PEER" | jq -r '.Online // false')
        ACTIVE=$(echo "$PEER" | jq -r '.Active // false')
        RX=$(echo "$PEER" | jq -r '.RxBytes // 0')
        TX=$(echo "$PEER" | jq -r '.TxBytes // 0')
        EXIT_NODE=$(echo "$PEER" | jq -r '.ExitNode // false')
        LAST_HS=$(echo "$PEER" | jq -r '.LastHandshake // "0001-01-01T00:00:00Z"')

        # Online
        if [[ "$ONLINE" == "true" ]]; then
          echo "tailscale_peer_online{peer=\"$HOSTNAME\"} 1" >> "$METRICS_TMP"
        else
          echo "tailscale_peer_online{peer=\"$HOSTNAME\"} 0" >> "$METRICS_TMP"
        fi

        # Direct vs Relay (CurAddr non-empty = direct connection)
        if [[ -n "$CURADDR" && "$CURADDR" != "null" ]]; then
          echo "tailscale_peer_direct{peer=\"$HOSTNAME\"} 1" >> "$METRICS_TMP"
        else
          echo "tailscale_peer_direct{peer=\"$HOSTNAME\"} 0" >> "$METRICS_TMP"
        fi

        # Active
        if [[ "$ACTIVE" == "true" ]]; then
          echo "tailscale_peer_active{peer=\"$HOSTNAME\"} 1" >> "$METRICS_TMP"
        else
          echo "tailscale_peer_active{peer=\"$HOSTNAME\"} 0" >> "$METRICS_TMP"
        fi

        # Exit node
        if [[ "$EXIT_NODE" == "true" ]]; then
          echo "tailscale_peer_exit_node{peer=\"$HOSTNAME\"} 1" >> "$METRICS_TMP"
        else
          echo "tailscale_peer_exit_node{peer=\"$HOSTNAME\"} 0" >> "$METRICS_TMP"
        fi

        # Bytes counters
        echo "tailscale_peer_rx_bytes_total{peer=\"$HOSTNAME\"} $RX" >> "$METRICS_TMP"
        echo "tailscale_peer_tx_bytes_total{peer=\"$HOSTNAME\"} $TX" >> "$METRICS_TMP"

        # Last handshake (seconds ago)
        if [[ "$LAST_HS" != "0001-01-01T00:00:00Z" && "$LAST_HS" != "null" ]]; then
          HS_EPOCH=$(date -d "$LAST_HS" +%s 2>/dev/null || echo 0)
          if [[ "$HS_EPOCH" -gt 0 ]]; then
            HS_AGO=$((NOW - HS_EPOCH))
            echo "tailscale_peer_last_handshake_seconds_ago{peer=\"$HOSTNAME\"} $HS_AGO" >> "$METRICS_TMP"
          fi
        fi

        # Info label metric (for joining metadata in queries)
        # Escape quotes in curaddr
        CURADDR_SAFE=''${CURADDR//\"/\\\"}
        echo "tailscale_peer_info{peer=\"$HOSTNAME\",os=\"$OS\",relay=\"$RELAY\",curaddr=\"$CURADDR_SAFE\"} 1" >> "$METRICS_TMP"
      done

      # Atomic replace with world-readable permissions for Alloy
      chmod 644 "$METRICS_TMP"
      mv "$METRICS_TMP" "$METRICS_FILE"
    '';
  };
in {
  options.atro.tailscale-exporter = {
    enable = mkEnableOption "Tailscale per-peer metrics exporter (from tailscale status --json)";

    interval = mkOption {
      type = types.str;
      default = "30s";
      description = "How often to collect peer metrics";
    };

    metricsPath = mkOption {
      type = types.str;
      default = "/var/lib/alloy/tailscale-peers.prom";
      description = "Path to write per-peer Prometheus metrics";
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d ${builtins.dirOf cfg.metricsPath} 0755 root root -"
      ];

      services.tailscale-exporter = {
        description = "Tailscale per-peer metrics exporter";
        after = ["tailscaled.service"];
        wants = ["tailscaled.service"];

        environment = {
          TAILSCALE_EXPORTER_METRICS_FILE = cfg.metricsPath;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${exporterScript}/bin/tailscale-exporter";
          ProtectSystem = "strict";
          PrivateTmp = true;
          ReadWritePaths = [(builtins.dirOf cfg.metricsPath)];
        };
      };

      timers.tailscale-exporter = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = cfg.interval;
          RandomizedDelaySec = "5s";
        };
      };
    };
  };
}
