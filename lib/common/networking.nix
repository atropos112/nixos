_: {
  # Networking basics (hostname excluded)
  networking = {
    usePredictableInterfaceNames = false;
    nftables.enable = false; # prefer iptables still
    firewall.enable = false;
    enableIPv6 = true;
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
}
