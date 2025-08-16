{config, ...}: {
  imports = [
    ../basic.nix
    ../../kubernetes/agent.nix
    ../server.nix
  ];

  topology.self = {
    name = config.networking.hostName;
    interfaces = {
      tailscale0.addresses = [config.networking.hostName];
      eth0.network = "LAN";
    };
    hardware.info = "RK3588S, 16GB (DDR4), Orange Pi 5, K8s Worker";
  };

  services.k3s.extraFlags = [
    "--node-label power-usage=low"
  ];
}
