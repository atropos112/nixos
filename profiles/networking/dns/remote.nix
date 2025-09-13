_: {
  services.dnsproxy.settings.upstream = [
    # Over tailscale
    "100.91.21.102" # OpnSense
    "100.124.150.44" # Orth
  ];
}
