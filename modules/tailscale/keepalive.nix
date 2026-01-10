{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.atro.tailscale.keepalive;
  inherit (lib) mkEnableOption mkOption mkIf types;

  # ============================================================================
  # Keepalive: ping all peers regularly to maintain NAT holes
  # ============================================================================
  keepaliveScript = pkgs.writeShellApplication {
    name = "tailscale-keepalive";
    runtimeInputs = with pkgs; [tailscale jq coreutils];
    text = ''
      set -euo pipefail

      # Get status JSON
      STATUS=$(tailscale status --json 2>/dev/null || echo '{}')
      SELF_HOSTNAME=$(echo "$STATUS" | jq -r '.Self.HostName // ""')

      # Ping each online peer with a single ping
      echo "$STATUS" | jq -r '.Peer // {} | to_entries[] | @json' | while read -r peer_json; do
        PEER=$(echo "$peer_json" | jq -r '.value')
        HOSTNAME=$(echo "$PEER" | jq -r '.HostName // "unknown"')
        ONLINE=$(echo "$PEER" | jq -r '.Online // false')

        # Skip self and localhost
        if [[ "$HOSTNAME" == "$SELF_HOSTNAME" || "$HOSTNAME" == "localhost" || -z "$HOSTNAME" ]]; then
          continue
        fi

        # Only ping online peers
        if [[ "$ONLINE" == "true" ]]; then
          # Fire and forget - don't wait for result, just trigger NAT traversal
          tailscale ping --timeout=5s -c 3 "$HOSTNAME" >/dev/null 2>&1 &
        fi
      done

      # Wait for all background pings to complete (with timeout)
      wait
    '';
  };
in {
  options.atro.tailscale.keepalive = {
    enable = mkEnableOption "Tailscale keepalive (ping all peers regularly)";

    interval = mkOption {
      type = types.str;
      default = "10s";
      description = "How often to ping all peers";
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.tailscale-keepalive = {
        description = "Tailscale keepalive (ping all peers)";
        after = ["tailscaled.service"];
        wants = ["tailscaled.service"];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${keepaliveScript}/bin/tailscale-keepalive";
          # Keep it lightweight
          Nice = 19;
          IOSchedulingClass = "idle";
        };
      };

      timers.tailscale-keepalive = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = cfg.interval;
        };
      };
    };
  };
}
