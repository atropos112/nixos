# Tailscale Watchdog

A state machine that monitors Tailscale peer connections and automatically restarts `tailscaled` when any peer is stuck using DERP relay instead of direct connections.

## Problem

Tailscale occasionally gets "stuck" on DERP relay connections even when direct connections should be possible. This causes:

- Higher latency
- Reduced throughput
- Dependency on relay infrastructure

A restart of `tailscaled` typically re-establishes direct connections.

## State Machine

Each peer is tracked independently with the following states:

```text
                                    ┌─────────────────┐
                                    │                 │
                    ┌───────────────│     DIRECT      │◄──────────────┐
                    │               │   (state: 0)    │               │
                    │               │                 │               │
                    │               └────────┬────────┘               │
                    │                        │                        │
                    │            Peer goes on relay                   │
                    │            (CurAddr becomes empty)              │
                    │                        │                        │
                    │                        ▼                        │
                    │               ┌─────────────────┐               │
                    │               │                 │               │
                    │               │ RELAY_DETECTED  │               │
                    │               │   (state: 1)    │               │
                    │               │                 │               │
                    │               └────────┬────────┘               │
                    │                        │                        │
                    │               Next watchdog run                 │
                    │               (still on relay)                  │
                    │                        │                        │
                    │                        ▼                        │
                    │               ┌─────────────────┐               │
    Peer returns    │               │                 │               │  Peer returns
    to direct       │               │  RELAY_WAITING  │───────────────┘  to direct
    connection      │               │   (state: 2)    │
                    │               │                 │
                    │               └────────┬────────┘
                    │                        │
                    │           duration > maxRelaySeconds
                    │                        │
                    │                        ▼
                    │               ┌─────────────────┐
                    │               │                 │
                    └───────────────│    RESTART      │
                                    │   TRIGGERED     │
                                    │                 │
                                    └─────────────────┘
                                             │
                                    systemctl restart tailscaled
```

## States

| State | Value | Description |
| ----- | ----- | ----------- |
| `DIRECT` | 0 | Peer has direct connection (`CurAddr` is set) |
| `RELAY_DETECTED` | 1 | Peer just transitioned to relay (first observation) |
| `RELAY_WAITING` | 2 | Peer has been on relay for multiple check intervals |

## Transitions

| From | To | Trigger |
| ---- | -- | ------- |
| DIRECT | RELAY_DETECTED | `CurAddr` becomes empty while peer is online |
| RELAY_DETECTED | RELAY_WAITING | Still on relay at next watchdog run |
| RELAY_WAITING | RELAY_WAITING | Still on relay, duration < threshold |
| RELAY_WAITING | RESTART | Duration > threshold |
| RELAY_* | DIRECT | `CurAddr` becomes non-empty (recovery) |

## Configuration

```nix
{
  atro.tailscale-watchdog = {
    enable = true;

    # Seconds on relay before restart (default: 600 = 10 min)
    maxRelaySeconds = 600;

    # Check interval (default: 1min)
    interval = "1min";

    # Metrics output path
    metricsPath = "/var/lib/alloy/tailscale-watchdog.prom";
  };
}
```

## Metrics

The watchdog exposes Prometheus metrics about its own state:

### Counters (cumulative)

| Metric | Description |
| ------ | ----------- |
| `tailscale_watchdog_restarts_total` | Total times watchdog restarted tailscaled |
| `tailscale_watchdog_relay_detections_total` | Total DIRECT→RELAY transitions observed |
| `tailscale_watchdog_recoveries_total` | Total RELAY→DIRECT transitions observed |

### Gauges (current state)

| Metric | Labels | Description |
| ------ | ------ | ----------- |
| `tailscale_watchdog_peer_state` | `peer` | Current state (0=direct, 1=detected, 2=waiting) |
| `tailscale_watchdog_peer_relay_duration_seconds` | `peer` | Seconds peer has been on relay (0 if direct) |
| `tailscale_watchdog_last_run_timestamp_seconds` | - | Unix timestamp of last watchdog execution |

## Logs

The watchdog logs to journald with tag `tailscale-watchdog`:

```bash
journalctl -t tailscale-watchdog -f
```

Log messages:

- `DETECTED: <peer> transitioned to relay` - State: DIRECT → RELAY_DETECTED
- `WAITING: <peer> on relay for Xs (max: Ys)` - State: RELAY_WAITING, waiting for threshold
- `RECOVERED: <peer> back to direct` - State: RELAY_* → DIRECT
- `RESTART: <peer> on relay for Xs (>Ys)` - Triggering restart

## Files

| Path | Purpose |
| ---- | ------- |
| `/var/lib/tailscale-watchdog/peer_<name>` | Timestamp when peer entered relay state |
| `/var/lib/tailscale-watchdog/.restart_count` | Cumulative restart counter |
| `/var/lib/tailscale-watchdog/.detection_count` | Cumulative detection counter |
| `/var/lib/tailscale-watchdog/.recovery_count` | Cumulative recovery counter |

## Related Modules

- `atro.tailscale-exporter` - Per-peer metrics from `tailscale status --json`
- Native Tailscale metrics via `tailscale metrics print` (aggregate traffic)

## Alerting

Example VMRule for alerting:

```yaml
- alert: TailscaleWatchdogRestartsHigh
  expr: increase(tailscale_watchdog_restarts_total[1h]) > 2
  labels:
    severity: warning
  annotations:
    summary: "Tailscale watchdog restarting frequently on {{ $labels.instance }}"
```
