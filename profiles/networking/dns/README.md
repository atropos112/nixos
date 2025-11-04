# DNS

## Node DNS Setups

The setup is divided into three types

- NixOS based node running DNSProxy (no AdGuard Home).
- NixOS based node running AdGuard Home and Unbound (not DNSProxy).
- Non-NixOS device like a phone.

### NixOS with DNSProxy

Divided into 3 cases based on location/usage. A node is exclusively one of the following:

- london
- stoke
- remote

Based on that it uses different adguard home's to connect to, possibly different ways of connecting to them (local vs tailscale).

```mermaid
graph TB
    subgraph NixOS["NixOS Node"]
        DNSProxy["DNSProxy<br/>127.0.0.1:53"]
    end

    subgraph OpnSense["OpnSense Node"]
        AGH1["AdGuard Home<br/>9.0.0.1 (local)<br/>100.91.21.102 (tailscale)"]
        UB1["Unbound<br/>127.0.0.1:5553 (local)<br/>100.91.21.102:5553 (tailscale)"]
    end

    subgraph Orth["Orth Node"]
        AGH2["AdGuard Home<br/>192.168.68.53 (local)<br/>100.124.150.44 (tailscale)"]
        UB2["Unbound<br/>127.0.0.1:5553 (local)<br/>100.124.150.44:5553 (tailscale)"]
    end

    subgraph Tailscale["Tailscale Magic DNS"]
        MagicDNS["100.100.100.100<br/>*.zapus-perch.ts.net"]
    end

    %% DNSProxy upstream connections based on location
    DNSProxy -->|"Stoke: 192.168.68.53"| AGH2
    DNSProxy -->|"London: 9.0.0.1"| AGH1
    DNSProxy -->|"Remote: 100.91.21.102"| AGH1
    DNSProxy -->|"Remote: 100.124.150.44"| AGH2
    DNSProxy -->|"*.zapus-perch.ts.net"| MagicDNS

    %% OpnSense AdGuard Home to Unbound connections
    AGH1 -->|"Local: 127.0.0.1:5553"| UB1
    AGH1 -->|"*.zapus-perch.ts.net"| MagicDNS

    %% Orth AdGuard Home to Unbound connections
    AGH2 -->|"Local: 127.0.0.1:5553"| UB2
    AGH2 -->|"*.zapus-perch.ts.net"| MagicDNS

    %% Styling
    classDef nodeBox fill:#2d3748,stroke:#4fd1c7,stroke-width:2px,color:#ffffff
    classDef serviceBox fill:#1a202c,stroke:#63b3ed,stroke-width:2px,color:#ffffff
    classDef dnsProxy fill:#4a5568,stroke:#f6ad55,stroke-width:2px,color:#ffffff
    classDef magicDNS fill:#553c9a,stroke:#9f7aea,stroke-width:2px,color:#ffffff

    class NixOS,OpnSense,Orth,Tailscale nodeBox
    class AGH1,AGH2,UB1,UB2 serviceBox
    class DNSProxy dnsProxy
    class MagicDNS magicDNS
```

> [!NOTE]
> Although adguard home will resolve `*.zapus-perch.ts.net` to `100.100.100.100`, the DNSProxy will
> actually not forward those queries to adguard home anyway but it will itself resolve `*.zapus-perch.ts.net`
> directly to `100.100.100.100`. The reason AdGuard Home has the resolving is for the case below.

### NixOS with AdGuard Home and Unbound

In this case showing how Orth is configured, but in principle adding any other node, would trivially generalise.

```mermaid
graph TB
    subgraph NixOSOrth["NixOS Node (Orth Location)"]
        LocalAGH["AdGuard Home<br/>127.0.0.1:53 (local)<br/>100.124.150.44 (tailscale)"]
        LocalUB["Unbound<br/>127.0.0.1:5553 (local)<br/>100.124.150.44:5553 (tailscale)"]
    end

    subgraph Tailscale["Tailscale Magic DNS"]
        MagicDNS["100.100.100.100<br/>*.zapus-perch.ts.net"]
    end

    %% Local AdGuard Home upstream connections
    LocalAGH -->|"Local: 127.0.0.1:5553"| LocalUB
    LocalAGH -->|"*.zapus-perch.ts.net"| MagicDNS

    %% Styling
    classDef nodeBox fill:#2d3748,stroke:#4fd1c7,stroke-width:2px,color:#ffffff
    classDef serviceBox fill:#1a202c,stroke:#63b3ed,stroke-width:2px,color:#ffffff
    classDef localAGH fill:#4a5568,stroke:#f6ad55,stroke-width:2px,color:#ffffff
    classDef magicDNS fill:#553c9a,stroke:#9f7aea,stroke-width:2px,color:#ffffff

    class NixOSOrth,OpnSense,Tailscale nodeBox
    class LocalUB serviceBox
    class LocalAGH localAGH
    class MagicDNS magicDNS
```

### Non-NixOS Device

```mermaid
graph TB
    subgraph Device["Non-NixOS Device (Phone/etc)"]
        ClientDNS["Device DNS<br/>(Tailscale Override)"]
    end

    subgraph TailscaleDNS["Tailscale Magic DNS"]
        MagicDNS["100.100.100.100<br/>DNS Override Config"]
    end

    subgraph OpnSense["OpnSense Node"]
        AGH1["AdGuard Home<br/>9.0.0.1 (local)<br/>100.91.21.102 (tailscale)"]
        UB1["Unbound<br/>127.0.0.1:5553 (local)<br/>100.91.21.102:5553 (tailscale)"]
    end

    subgraph Orth["Orth Node"]
        AGH2["AdGuard Home<br/>192.168.68.53 (local)<br/>100.124.150.44 (tailscale)"]
        UB2["Unbound<br/>127.0.0.1:5553 (local)<br/>100.124.150.44:5553 (tailscale)"]
    end

    %% Device to Tailscale Magic DNS
    ClientDNS -->|"All DNS Queries"| MagicDNS

    %% Tailscale Magic DNS to AdGuard instances (Tailscale IPs only)
    MagicDNS -->|"100.91.21.102"| AGH1
    MagicDNS -->|"100.124.150.44"| AGH2

    %% OpnSense AdGuard Home to Unbound connections
    AGH1 -->|"Local: 127.0.0.1:5553"| UB1
    AGH1 -->|"*.zapus-perch.ts.net"| MagicDNS

    %% Orth AdGuard Home to Unbound connections
    AGH2 -->|"Local: 127.0.0.1:5553"| UB2
    AGH2 -->|"*.zapus-perch.ts.net"| MagicDNS

    %% Styling
    classDef nodeBox fill:#2d3748,stroke:#4fd1c7,stroke-width:2px,color:#ffffff
    classDef serviceBox fill:#1a202c,stroke:#63b3ed,stroke-width:2px,color:#ffffff
    classDef clientDevice fill:#4a5568,stroke:#f6ad55,stroke-width:2px,color:#ffffff
    classDef magicDNS fill:#553c9a,stroke:#9f7aea,stroke-width:2px,color:#ffffff

    class Device,OpnSense,Orth,TailscaleDNS nodeBox
    class AGH1,AGH2,UB1,UB2 serviceBox
    class ClientDNS clientDevice
    class MagicDNS magicDNS
```

> [!NOTE]
> The fact that AdGuard Home would resolve `*.zapus-perch.ts.net` to `100.100.100.100` is only in the picture for completeness.
> It would never actually be used as we go through `100.100.100.100` in the first place and it would
> resolve the `*.zapus-perch.ts.net` directly there and not pass through to AdGuard Home, there is no cyclic dependency (contrary to what the diagram might suggest).

## DNS serving configurations

### Orth

- Declared mostly in NixOS, allowing for edits in UI (discouraged) but overwritten by NixOS.
- Unbound is declared entirely in NixOS.

### OpnSense

- Not declared, installed manually via the OpnSense UI with external library that had to be added also.

### Tailscale

- Manually set DNS global nameservers to be orth and opnsense Tailscale IPs, so that all Tailscale clients use them for DNS resolution.
