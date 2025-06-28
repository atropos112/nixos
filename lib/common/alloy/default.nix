{
  pkgs,
  lib,
  ...
}: {
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:12346"
      "--feature.community-components.enabled"
      "--disable-reporting"
    ];
    package = pkgs.grafana-alloy;
    configPath = ./config.alloy;
  };

  # Overriding the default config to include docker for docker socket access
  systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkForce [
    # allow to read the systemd journal for loki log forwarding
    "systemd-journal"
    # allow to read the docker socket
    "podman"
  ];
}
