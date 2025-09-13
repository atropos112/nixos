{config, ...}: {
  # Networking basics (hostname excluded)
  networking = {
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
  };

  services.dnsproxy = {
    enable = !config.services.adguardhome.enable; # Turn on the dnsproxy service if its not running adguardhome directly
    settings = {
      cache = true; # Enables caching of DNS responses.
      cache-min-ttl = 1; # Sets the minimum time-to-live for cached entries to 1 second.
      cache-max-ttl = 300; # Sets the maximum time-to-live for cached entries to 5 minutes.
      cache-optimistic = true; # Responds from cache even when the entries are expired but then refreshes them.
      cache-size = 4194304; # Sets the cache size to 4 MiB.
      fallback = ["9.9.9.9"]; # Fallback DNS server if upstreams fail.
      listen-addrs = ["127.0.0.1"]; # Listens on your local computer (127.0.0.1).
      listen-ports = [53]; # Default DNS port (port 53). This will handle DNS requests.
      upstream = [
        # Locals
        # "9.0.0.1"
        # "192.168.68.53"
        # Tailscale
        "100.100.100.100"
      ];
      upstream-mode = "parallel";
      verbose = true;
    };
  };
}
