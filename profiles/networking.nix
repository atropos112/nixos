{
  options,
  config,
  ...
}: {
  # Networking basics (hostname excluded)
  networking = {
    usePredictableInterfaceNames = false;
    nftables.enable = true;
    firewall.enable = false;
    nameservers = ["127.0.0.1"];
    networkmanager.appendNameservers = ["127.0.0.1"];
    resolvconf = {
      # This config (with tailsacle) will result in a /etc/resolv.conf like this:
      # search zapus-perch.ts.net
      # nameserver 127.0.0.1
      # options edns0 trust-ad

      useLocalResolver = true;
      dnsExtensionMechanism = true;
    };
    enableIPv6 = false;
    # Some time servers just to be sure
    timeServers =
      options.networking.timeServers.default
      ++ [
        "time-a-g.nist.gov"
        "utcnist3.colorado.edu"
        "0.europe.pool.ntp.org"
        "1.europe.pool.ntp.org"
        "2.europe.pool.ntp.org"
        "3.europe.pool.ntp.org"
      ];
  };

  systemd = {
    services = {
      NetworkManager-wait-online.enable = false;

      # Do not take down the network for too long when upgrading,
      # This also prevents failures of services that are restarted instead of stopped.
      # It will use `systemctl restart` rather than stopping it with `systemctl stop`
      # followed by a delayed `systemctl start`.
      systemd-networkd.stopIfChanged = false;

      # Services that are only restarted might be not able to resolve when resolved is stopped before
      systemd-resolved.stopIfChanged = false;

      systemd-networkd-wait-online.enable = true;
    };
  };

  services = {
    dnsproxy = {
      enable = !config.services.adguardhome.enable; # Turn on the dnsproxy service if its not running adguardhome directly
      settings = {
        cache = true; # Enables caching of DNS responses.
        cache-max-ttl = 300; # Sets the maximum time-to-live for cached entries to 5 minutes.
        cache-optimistic = true; # Responds from cache even when the entries are expired but then refreshes them.
        cache-size = 4194304; # Sets the cache size to 4 MiB.
        fallback = ["9.9.9.9"]; # Fallback DNS server if upstreams fail.
        listen-addrs = ["127.0.0.1"]; # Listens on your local computer (127.0.0.1).
        listen-ports = [53]; # Default DNS port (port 53). This will handle DNS requests.
        upstream = [
          # Locals
          "9.0.0.1"
          "192.168.68.53"
          # Tailscale
          "100.100.100.100"
        ];
        upstream-mode = "parallel";
        verbose = true;
      };
    };
  };
}
