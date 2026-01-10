{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.atro.tailscale-watchdog;
  inherit (lib) mkEnableOption mkOption mkIf types;

  # ============================================================================
  # Watchdog with Ping-First Recovery
  # ============================================================================
  # When a peer is stuck on relay too long:
  # 1. First try `tailscale ping` to trigger direct connection
  # 2. Only restart tailscaled if ping fails to establish direct
  #
  # See README.md in this directory for full documentation.
  # ============================================================================
  watchdogScript = pkgs.writeShellApplication {
    name = "tailscale-watchdog";
    runtimeInputs = with pkgs; [tailscale jq coreutils systemd util-linux];
    text = ''
      set -euo pipefail

      STATE_DIR="''${TAILSCALE_WATCHDOG_STATE_DIR:-/var/lib/tailscale-watchdog}"
      METRICS_FILE="''${TAILSCALE_WATCHDOG_METRICS_FILE:-/var/lib/alloy/tailscale-watchdog.prom}"
      MAX_RELAY_SECONDS="''${TAILSCALE_WATCHDOG_MAX_RELAY_SECONDS:-600}"
      PING_TIMEOUT="''${TAILSCALE_WATCHDOG_PING_TIMEOUT:-10s}"

      mkdir -p "$STATE_DIR" "$(dirname "$METRICS_FILE")"

      # Load counters
      RESTART_COUNT=$(cat "$STATE_DIR/.restart_count" 2>/dev/null || echo 0)
      DETECTION_COUNT=$(cat "$STATE_DIR/.detection_count" 2>/dev/null || echo 0)
      RECOVERY_COUNT=$(cat "$STATE_DIR/.recovery_count" 2>/dev/null || echo 0)
      PING_ATTEMPT_COUNT=$(cat "$STATE_DIR/.ping_attempt_count" 2>/dev/null || echo 0)
      PING_SUCCESS_COUNT=$(cat "$STATE_DIR/.ping_success_count" 2>/dev/null || echo 0)

      # Temp file for atomic metrics write
      METRICS_TMP=$(mktemp)
      trap 'rm -f "$METRICS_TMP"' EXIT

      cat > "$METRICS_TMP" << 'HEADER'
      # HELP tailscale_watchdog_restarts_total Total times watchdog restarted tailscaled
      # TYPE tailscale_watchdog_restarts_total counter
      # HELP tailscale_watchdog_relay_detections_total Total times a peer was detected on relay
      # TYPE tailscale_watchdog_relay_detections_total counter
      # HELP tailscale_watchdog_recoveries_total Total times a peer recovered to direct (naturally)
      # TYPE tailscale_watchdog_recoveries_total counter
      # HELP tailscale_watchdog_ping_attempts_total Total ping attempts to establish direct connection
      # TYPE tailscale_watchdog_ping_attempts_total counter
      # HELP tailscale_watchdog_ping_successes_total Pings that successfully established direct connection
      # TYPE tailscale_watchdog_ping_successes_total counter
      # HELP tailscale_watchdog_peer_state Current state per peer (0=direct, 1=relay_detected, 2=relay_waiting)
      # TYPE tailscale_watchdog_peer_state gauge
      # HELP tailscale_watchdog_peer_relay_duration_seconds How long peer has been on relay
      # TYPE tailscale_watchdog_peer_relay_duration_seconds gauge
      # HELP tailscale_watchdog_last_run_timestamp_seconds Unix timestamp of last watchdog run
      # TYPE tailscale_watchdog_last_run_timestamp_seconds gauge
      HEADER

      # Get status JSON
      STATUS=$(tailscale status --json 2>/dev/null || echo '{}')
      SELF_HOSTNAME=$(echo "$STATUS" | jq -r '.Self.HostName // ""')
      NOW=$(date +%s)

      echo "tailscale_watchdog_last_run_timestamp_seconds $NOW" >> "$METRICS_TMP"

      # Check cooldown - don't restart if we restarted recently
      LAST_RESTART=$(cat "$STATE_DIR/.last_restart" 2>/dev/null || echo 0)
      COOLDOWN_REMAINING=$((LAST_RESTART + MAX_RELAY_SECONDS - NOW))

      # Process each peer (skip self and localhost)
      echo "$STATUS" | jq -r '.Peer // {} | to_entries[] | @json' | while read -r peer_json; do
        PEER=$(echo "$peer_json" | jq -r '.value')
        HOSTNAME=$(echo "$PEER" | jq -r '.HostName // "unknown"')

        # Skip self and localhost
        if [[ "$HOSTNAME" == "$SELF_HOSTNAME" || "$HOSTNAME" == "localhost" || -z "$HOSTNAME" ]]; then
          continue
        fi
        CURADDR=$(echo "$PEER" | jq -r '.CurAddr // ""')
        ONLINE=$(echo "$PEER" | jq -r '.Online // false')

        state_file="$STATE_DIR/peer_$HOSTNAME"

        # Determine if on relay (online but no direct address)
        is_relay=0
        if [[ "$ONLINE" == "true" && ( -z "$CURADDR" || "$CURADDR" == "null" ) ]]; then
          is_relay=1
        fi

        if [[ "$is_relay" -eq 1 ]]; then
          if [[ -f "$state_file" ]]; then
            first_seen=$(cat "$state_file")
            relay_duration=$((NOW - first_seen))

            # State: RELAY_WAITING
            {
              echo "tailscale_watchdog_peer_state{peer=\"$HOSTNAME\"} 2"
              echo "tailscale_watchdog_peer_relay_duration_seconds{peer=\"$HOSTNAME\"} $relay_duration"
            } >> "$METRICS_TMP"

            # Check if peer has been on relay too long
            # Try ping each iteration to trigger NAT traversal
            logger -t tailscale-watchdog "WAITING: $HOSTNAME on relay for ''${relay_duration}s (threshold: ''${MAX_RELAY_SECONDS}s), pinging..."
            PING_ATTEMPT_COUNT=$((PING_ATTEMPT_COUNT + 1))
            echo "$PING_ATTEMPT_COUNT" > "$STATE_DIR/.ping_attempt_count"

            if tailscale ping --timeout="$PING_TIMEOUT" -c 3 "$HOSTNAME" >/dev/null 2>&1; then
              sleep 1
              # Re-check if now direct
              NEW_STATUS=$(tailscale status --json 2>/dev/null || echo '{}')
              NEW_CURADDR=$(echo "$NEW_STATUS" | jq -r ".Peer | to_entries[] | select(.value.HostName == \"$HOSTNAME\") | .value.CurAddr // \"\"")

              if [[ -n "$NEW_CURADDR" && "$NEW_CURADDR" != "null" && "$NEW_CURADDR" != "" ]]; then
                logger -t tailscale-watchdog "PING_SUCCESS: $HOSTNAME now direct after ping"
                PING_SUCCESS_COUNT=$((PING_SUCCESS_COUNT + 1))
                echo "$PING_SUCCESS_COUNT" > "$STATE_DIR/.ping_success_count"
                rm -f "$state_file"

                {
                  echo "tailscale_watchdog_peer_state{peer=\"$HOSTNAME\"} 0"
                  echo "tailscale_watchdog_peer_relay_duration_seconds{peer=\"$HOSTNAME\"} 0"
                } >> "$METRICS_TMP"
                continue
              fi
            fi

            # Check if threshold exceeded - by now we've pinged many times, just restart
            if [[ "$relay_duration" -gt "$MAX_RELAY_SECONDS" ]]; then
              if [[ "$COOLDOWN_REMAINING" -gt 0 ]]; then
                logger -t tailscale-watchdog "COOLDOWN: $HOSTNAME exceeded threshold but in cooldown (''${COOLDOWN_REMAINING}s remaining)"
              else
                logger -t tailscale-watchdog "RESTART: $HOSTNAME on relay for ''${relay_duration}s, pings exhausted, restarting tailscaled"
                RESTART_COUNT=$((RESTART_COUNT + 1))
                echo "$RESTART_COUNT" > "$STATE_DIR/.restart_count"
                echo "$NOW" > "$STATE_DIR/.last_restart"

                rm -f "$STATE_DIR"/peer_*

                {
                  echo "tailscale_watchdog_restarts_total $RESTART_COUNT"
                  echo "tailscale_watchdog_relay_detections_total $DETECTION_COUNT"
                  echo "tailscale_watchdog_recoveries_total $RECOVERY_COUNT"
                  echo "tailscale_watchdog_ping_attempts_total $PING_ATTEMPT_COUNT"
                  echo "tailscale_watchdog_ping_successes_total $PING_SUCCESS_COUNT"
                } >> "$METRICS_TMP"
                chmod 644 "$METRICS_TMP"
                mv "$METRICS_TMP" "$METRICS_FILE"

                systemctl restart tailscaled
                exit 0
              fi
            fi
          else
            # State transition: DIRECT -> RELAY_DETECTED
            echo "$NOW" > "$state_file"
            DETECTION_COUNT=$((DETECTION_COUNT + 1))
            echo "$DETECTION_COUNT" > "$STATE_DIR/.detection_count"
            logger -t tailscale-watchdog "DETECTED: $HOSTNAME transitioned to relay"

            {
              echo "tailscale_watchdog_peer_state{peer=\"$HOSTNAME\"} 1"
              echo "tailscale_watchdog_peer_relay_duration_seconds{peer=\"$HOSTNAME\"} 0"
            } >> "$METRICS_TMP"
          fi
        else
          # State: DIRECT
          if [[ -f "$state_file" ]]; then
            # State transition: RELAY_* -> DIRECT (natural recovery)
            RECOVERY_COUNT=$((RECOVERY_COUNT + 1))
            echo "$RECOVERY_COUNT" > "$STATE_DIR/.recovery_count"
            logger -t tailscale-watchdog "RECOVERED: $HOSTNAME back to direct (natural)"
            rm -f "$state_file"
          fi

          {
            echo "tailscale_watchdog_peer_state{peer=\"$HOSTNAME\"} 0"
            echo "tailscale_watchdog_peer_relay_duration_seconds{peer=\"$HOSTNAME\"} 0"
          } >> "$METRICS_TMP"
        fi
      done

      # Write counters
      {
        echo "tailscale_watchdog_restarts_total $RESTART_COUNT"
        echo "tailscale_watchdog_relay_detections_total $DETECTION_COUNT"
        echo "tailscale_watchdog_recoveries_total $RECOVERY_COUNT"
        echo "tailscale_watchdog_ping_attempts_total $PING_ATTEMPT_COUNT"
        echo "tailscale_watchdog_ping_successes_total $PING_SUCCESS_COUNT"
      } >> "$METRICS_TMP"

      # Atomic replace with world-readable permissions for Alloy
      chmod 644 "$METRICS_TMP"
      mv "$METRICS_TMP" "$METRICS_FILE"
    '';
  };
in {
  options.atro.tailscale-watchdog = {
    enable = mkEnableOption "Tailscale connection watchdog with ping-first recovery";

    interval = mkOption {
      type = types.str;
      default = "1min";
      description = "How often to check peer connections";
    };

    maxRelaySeconds = mkOption {
      type = types.int;
      default = 600;
      description = "Seconds a peer can be on relay before attempting recovery";
    };

    pingTimeout = mkOption {
      type = types.str;
      default = "10s";
      description = "Timeout for ping attempts";
    };

    metricsPath = mkOption {
      type = types.str;
      default = "/var/lib/alloy/tailscale-watchdog.prom";
      description = "Path to write watchdog metrics";
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d /var/lib/tailscale-watchdog 0755 root root -"
        "d ${builtins.dirOf cfg.metricsPath} 0755 root root -"
      ];

      services.tailscale-watchdog = {
        description = "Tailscale connection watchdog (ping-first recovery)";
        after = ["tailscaled.service"];
        wants = ["tailscaled.service"];

        environment = {
          TAILSCALE_WATCHDOG_MAX_RELAY_SECONDS = toString cfg.maxRelaySeconds;
          TAILSCALE_WATCHDOG_PING_TIMEOUT = cfg.pingTimeout;
          TAILSCALE_WATCHDOG_METRICS_FILE = cfg.metricsPath;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${watchdogScript}/bin/tailscale-watchdog";
          ProtectSystem = "strict";
          PrivateTmp = true;
          ReadWritePaths = ["/var/lib/tailscale-watchdog" (builtins.dirOf cfg.metricsPath)];
        };
      };

      timers.tailscale-watchdog = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = cfg.interval;
          RandomizedDelaySec = "10s";
        };
      };
    };
  };
}
