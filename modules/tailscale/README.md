# Tailscale NixOS Modules

This directory contains NixOS modules for Tailscale monitoring and maintenance.
All modules are enabled via `atro.tailscale.<module>` options.

## Modules Overview

| Module           | Purpose                                         | Interval |
| ---------------- | ----------------------------------------------- | -------- |
| `exporter`       | Per-peer metrics from `tailscale status --json` | 30s      |
| `native-metrics` | Native metrics via `tailscale metrics print`    | 15s      |
| `keepalive`      | Ping all peers to maintain NAT holes            | 10s      |
| `watchdog`       | Restart tailscaled if stuck on relay            | 1min     |

## Quick Start

```nix
atro.tailscale = {
  exporter.enable = true;
  native-metrics.enable = true;
  keepalive.enable = true;
  watchdog.enable = true;
};
```

## Module Details

### exporter

Parses `tailscale status --json` and exports per-peer Prometheus metrics.

**Metrics:**

| Metric                                      | Type    | Description                       |
| ------------------------------------------- | ------- | --------------------------------- |
| `tailscale_up`                              | gauge   | 1 if Running, 0 otherwise         |
| `tailscale_health_issues`                   | gauge   | Number of health issues           |
| `tailscale_version_info`                    | gauge   | Version info with labels          |
| `tailscale_peer_online`                     | gauge   | Per-peer: 1 if online             |
| `tailscale_peer_direct`                     | gauge   | Per-peer: 1 if direct connection  |
| `tailscale_peer_active`                     | gauge   | Per-peer: 1 if active traffic     |
| `tailscale_peer_rx_bytes_total`             | counter | Per-peer: bytes received          |
| `tailscale_peer_tx_bytes_total`             | counter | Per-peer: bytes transmitted       |
| `tailscale_peer_last_handshake_seconds_ago` | gauge   | Per-peer: seconds since handshake |
| `tailscale_peer_info`                       | gauge   | Per-peer: metadata labels         |

**Output:** `/var/lib/alloy/tailscale-peers.prom`

### native-metrics

Runs `tailscale metrics print` to export native Tailscale metrics (aggregate
counters for magicsock, netcheck, etc.).

**Output:** `/var/lib/alloy/tailscale-native.prom`

### keepalive

Proactively pings all online peers every 10 seconds to maintain NAT holes.
This keeps connections warm and helps establish direct connections.

**How it works:**

1. Gets list of online peers from `tailscale status --json`
2. Fires `tailscale ping -c 3` to each peer (background, fire-and-forget)
3. Wait for all pings to complete

This is lightweight (runs with low priority) and helps prevent connections
from falling back to relay due to NAT timeout.

### watchdog

Monitors peer connections and restarts tailscaled if peers are stuck on relay
for too long. This is the safety net when keepalive pings aren't enough.

**How it works:**

1. Every minute, check all online peers
2. If peer is on relay (no direct address), track when it started
3. If on relay for > 10 minutes AND not in cooldown, restart tailscaled
4. After restart, cooldown prevents another restart for 10 minutes

**Metrics:**

| Metric                                          | Type    | Description                        |
| ----------------------------------------------- | ------- | ---------------------------------- |
| `tailscale_watchdog_restarts_total`             | counter | Times tailscaled was restarted     |
| `tailscale_watchdog_relay_detections_total`     | counter | Times peers were detected on relay |
| `tailscale_watchdog_recoveries_total`           | counter | Times peers recovered naturally    |
| `tailscale_watchdog_peer_state`                 | gauge   | Per-peer: 0=direct, 1=relay        |
| `tailscale_watchdog_peer_relay_duration_seconds`| gauge   | Per-peer: seconds on relay         |
| `tailscale_watchdog_last_run_timestamp_seconds` | gauge   | Last watchdog run timestamp        |

**Output:** `/var/lib/alloy/tailscale-watchdog.prom`

**Logs:**

```bash
journalctl -t tailscale-watchdog -f
```

Example messages:

```text
DETECTED: hostname transitioned to relay
WAITING: hostname on relay for 300s (threshold: 600s)
RESTART: hostname on relay for 650s, restarting tailscaled
COOLDOWN: hostname exceeded threshold but in cooldown (200s remaining)
RECOVERED: hostname back to direct
```

## Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                      Tailscale Services                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐  ┌────────────────┐  ┌───────────┐  ┌──────────┐ │
│  │ exporter │  │ native-metrics │  │ keepalive │  │ watchdog │ │
│  │  (30s)   │  │     (15s)      │  │   (10s)   │  │  (1min)  │ │
│  └────┬─────┘  └───────┬────────┘  └─────┬─────┘  └────┬─────┘ │
│       │                │                 │              │       │
│       ▼                ▼                 ▼              ▼       │
│  peers.prom      native.prom      tailscale ping   watchdog.prom│
│       │                │           (NAT keepalive)      │       │
│       │                │                                │       │
│       └────────────────┴────────────────────────────────┘       │
│                        │                                        │
│                        ▼                                        │
│         ┌─────────────────────────────────────────────────┐     │
│         │                /var/lib/alloy/                  │     │
│         │    (scraped by prometheus.exporter.textfile)    │     │
│         └─────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Options

### atro.tailscale.exporter

| Option        | Type   | Default                                 | Description         |
| ------------- | ------ | --------------------------------------- | ------------------- |
| `enable`      | bool   | false                                   | Enable the exporter |
| `interval`    | string | "30s"                                   | Collection interval |
| `metricsPath` | string | "/var/lib/alloy/tailscale-peers.prom"   | Metrics output path |

### atro.tailscale.native-metrics

| Option        | Type   | Default                                  | Description           |
| ------------- | ------ | ---------------------------------------- | --------------------- |
| `enable`      | bool   | false                                    | Enable native metrics |
| `interval`    | string | "15s"                                    | Collection interval   |
| `metricsPath` | string | "/var/lib/alloy/tailscale-native.prom"   | Metrics output path   |

### atro.tailscale.keepalive

| Option     | Type   | Default | Description      |
| ---------- | ------ | ------- | ---------------- |
| `enable`   | bool   | false   | Enable keepalive |
| `interval` | string | "10s"   | Ping interval    |

### atro.tailscale.watchdog

| Option            | Type   | Default                                    | Description            |
| ----------------- | ------ | ------------------------------------------ | ---------------------- |
| `enable`          | bool   | false                                      | Enable watchdog        |
| `interval`        | string | "1min"                                     | Check interval         |
| `maxRelaySeconds` | int    | 600                                        | Seconds before restart |
| `metricsPath`     | string | "/var/lib/alloy/tailscale-watchdog.prom"   | Metrics output path    |

## Files

| Path                                        | Purpose                     |
| ------------------------------------------- | --------------------------- |
| `/var/lib/alloy/tailscale-peers.prom`       | Per-peer metrics (exporter) |
| `/var/lib/alloy/tailscale-native.prom`      | Native metrics              |
| `/var/lib/alloy/tailscale-watchdog.prom`    | Watchdog metrics            |
| `/var/lib/tailscale-watchdog/`              | Watchdog state directory    |
| `/var/lib/tailscale-watchdog/peer_*`        | Per-peer relay timestamps   |
| `/var/lib/tailscale-watchdog/.last_restart` | Last restart timestamp      |

## Alloy Integration

Configure Alloy to scrape the textfile metrics:

```river
prometheus.exporter.unix "tailscale_textfile" {
  enable_collectors = ["textfile"]
  textfile {
    directory = "/var/lib/alloy"
  }
}

prometheus.scrape "tailscale_textfile" {
  job_name   = "tailscale"
  forward_to = [prometheus.relabel.default.receiver]
  targets    = prometheus.exporter.unix.tailscale_textfile.targets
}
```
