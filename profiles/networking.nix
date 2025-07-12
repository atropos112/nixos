{options, ...}: {
  # Networking basics (hostname excluded)
  networking = {
    usePredictableInterfaceNames = false;
    nftables.enable = true;
    firewall.enable = false;
    # nameservers = ["127.0.0.1"];
    # networkmanager.appendNameservers = ["127.0.0.1"];
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
    };

    # What does it mean to be online?
    network.wait-online.enable = false;
  };

  # services = {
  #   dnsproxy = {
  #     enable = true; # Turn on the dnsproxy service
  #     settings = {
  #       cache = true; # Enables caching of DNS responses.
  #       cache-max-ttl = 600; # Sets the maximum time-to-live for cached entries to 10 minutes.
  #       cache-optimistic = true; # Responds from cache even when the entries are expired but then refreshes them.
  #       cache-size = 4194304; # Sets the cache size to 4 MiB.
  #       fallback = ["9.9.9.9"]; # Fallback DNS server if upstreams fail.
  #       listen-addrs = ["0.0.0.0"]; # Listens on your local computer (127.0.0.1).
  #       listen-ports = [53]; # Default DNS port (port 53). This will handle DNS requests.
  #       upstream = [
  #         "https://opnsense.zapus-perch.ts.net:9443/dns-query"
  #         "https://opiz2.zapus-perch.ts.net:9443/dns-query"
  #       ];
  #       upstream-mode = "parallel";
  #       verbose = true;
  #     };
  #   };
  # };
}
