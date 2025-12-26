{pkgs-stable, ...}: {
  # Unbound: recursive DNS resolver (no forwarders, queries root servers directly)
  # Privacy note: QNAME minimization is on by default, which reduces info leaked to each
  # nameserver in the chain. However, all queries are plaintext - ISP sees everything.
  # For true DNS privacy you'd need DoH/DoT, but then you're trusting that resolver.
  services.unbound = {
    enable = true;
    package = pkgs-stable.unbound;
    resolveLocalQueries = false; # Don't hijack /etc/resolv.conf
    checkconf = true; # Validate config at build time
    enableRootTrustAnchor = false; # Disable DNSSEC anchor fetch - prevents startup hang when network is flaky
    settings = {
      server = {
        port = "5553"; # Non-standard port, AdGuard Home connects here as upstream
        interface = ["0.0.0.0"];
        access-control = [
          "0.0.0.0/0 allow" # Wide open but fine - only AdGuard Home talks to this
        ];
        do-ip4 = "yes";
        do-udp = "yes";
        do-tcp = "yes";
        verbosity = "1";
      };
    };
  };

  users = {
    groups.unbound.gid = 988;

    users = {
      unbound = {
        uid = 996;
        group = "unbound";
      };
    };
  };
}
