# Tailscale Watchdog with Ping-First Recovery

## Problem

Tailscale peers sometimes get stuck on relay (DERP) connections when direct
connections should be possible. This can happen due to NAT traversal issues
that don't resolve on their own.

## Solution

This watchdog monitors peer connection states and attempts recovery using a
**ping-first approach**:

1. **Detection**: Track when peers transition from direct to relay
2. **Active Recovery**: Each check (every minute), ping the peer to trigger NAT traversal
3. **Restart Fallback**: Only restart tailscaled after threshold (default: 10 minutes of failed pings)

The key insight is that `tailscale ping` can trigger NAT hole-punching and
establish direct connections without the heavy-handed approach of restarting
the daemon. By pinging each iteration, we give ~10 opportunities to establish
direct connection before resorting to a restart.

## State Machine

```text
┌──────────┐  on relay   ┌────────────────┐
│  DIRECT  │ ──────────► │ RELAY_DETECTED │
└──────────┘             └───────┬────────┘
     ▲                           │
     │                           │ each minute: ping -c 3
     │                           ▼
     │    ping success   ┌───────────────┐
     │◄──────────────────┤ PING + WAIT   │◄─────┐
     │                   └───────┬───────┘      │
     │                           │              │ still on relay
     │                           │              │ threshold not reached
     │                           └──────────────┘
     │                           │
     │                           │ threshold exceeded (10 min)
     │                           ▼
     │                   ┌───────────────┐
     └◄──────────────────┤ RESTART       │
         after restart   │ TAILSCALED    │
                         └───────────────┘
```

## Metrics

The watchdog exports the following Prometheus metrics to a textfile:

### Counters (cumulative since first run)

| Metric                                       | Description                       |
| -------------------------------------------- | --------------------------------- |
| `tailscale_watchdog_restarts_total`          | Times tailscaled was restarted    |
| `tailscale_watchdog_relay_detections_total`  | Times a peer was detected on relay|
| `tailscale_watchdog_recoveries_total`        | Times a peer recovered naturally  |
| `tailscale_watchdog_ping_attempts_total`     | Ping attempts to establish direct |
| `tailscale_watchdog_ping_successes_total`    | Pings that established direct     |

### Gauges (per-peer)

| Metric                                           | Labels | Description                                 |
| ------------------------------------------------ | ------ | ------------------------------------------- |
| `tailscale_watchdog_peer_state`                  | `peer` | 0=direct, 1=relay_detected, 2=relay_waiting |
| `tailscale_watchdog_peer_relay_duration_seconds` | `peer` | Seconds on relay                            |

### Other

| Metric                                          | Description                |
| ----------------------------------------------- | -------------------------- |
| `tailscale_watchdog_last_run_timestamp_seconds` | Unix timestamp of last run |

## Configuration

```nix
atro.tailscale-watchdog = {
  enable = true;

  # How often to check (default: 1min)
  interval = "1min";

  # Seconds on relay before attempting recovery (default: 600 = 10 minutes)
  maxRelaySeconds = 600;

  # Timeout for ping attempts (default: 10s)
  pingTimeout = "10s";

  # Where to write metrics (default: /var/lib/alloy/tailscale-watchdog.prom)
  metricsPath = "/var/lib/alloy/tailscale-watchdog.prom";
};
```

## How It Works

1. Every `interval` (default: 1 minute), the watchdog runs and:
   - Gets `tailscale status --json`
   - For each online peer, checks if they have a direct connection (`CurAddr`)
   - Tracks state transitions in `/var/lib/tailscale-watchdog/`

2. While a peer is on relay:
   - Each iteration, attempts `tailscale ping -c 3 <hostname>`
   - If ping establishes direct connection: success, reset state
   - If still on relay: wait for next iteration

3. When relay duration exceeds `maxRelaySeconds` (default: 10 minutes):
   - By now we've tried ~10 ping attempts (30 pings total)
   - Check cooldown (won't restart if recently restarted)
   - If not in cooldown: restart tailscaled

4. Cooldown mechanism:
   - After a restart, won't restart again for `maxRelaySeconds`
   - Prevents restart loops

## Logs

Watch watchdog activity:

```bash
journalctl -t tailscale-watchdog -f
```

Example log messages:

```text
DETECTED: hostname transitioned to relay
WAITING: hostname on relay for 300s (threshold: 600s), pinging...
PING_SUCCESS: hostname now direct after ping
RESTART: hostname on relay for 650s, pings exhausted, restarting tailscaled
COOLDOWN: hostname exceeded threshold but in cooldown (200s remaining)
RECOVERED: hostname back to direct (natural)
```

## Files

| Path                                             | Purpose                            |
| ------------------------------------------------ | ---------------------------------- |
| `/var/lib/tailscale-watchdog/`                   | State directory                    |
| `/var/lib/tailscale-watchdog/peer_*`             | Per-peer relay detection timestamps|
| `/var/lib/tailscale-watchdog/.restart_count`     | Total restart counter              |
| `/var/lib/tailscale-watchdog/.detection_count`   | Relay detection counter            |
| `/var/lib/tailscale-watchdog/.recovery_count`    | Natural recovery counter           |
| `/var/lib/tailscale-watchdog/.ping_attempt_count`| Ping attempt counter               |
| `/var/lib/tailscale-watchdog/.ping_success_count`| Ping success counter               |
| `/var/lib/tailscale-watchdog/.last_restart`      | Timestamp of last restart          |
| `/var/lib/alloy/tailscale-watchdog.prom`         | Prometheus metrics textfile        |

## Why Ping First?

Restarting tailscaled is disruptive:

- Drops all existing connections
- Requires re-authentication
- Takes time to re-establish mesh

`tailscale ping` is lightweight and:

- Triggers NAT traversal attempts
- Can establish direct connections without daemon restart
- Doesn't affect other peers

In testing, ping successfully establishes direct connections in many cases
where the connection was simply "stuck" waiting for a trigger.
