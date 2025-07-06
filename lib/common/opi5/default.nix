_: {
  imports = [
    ../default.nix
    ../../../profiles/kubernetes/agent.nix
    ../server
    ./hardware.nix # Non standard, typically this is done from devices/<devicename>/hardware.nix but its the same across and always should be so importing it here instead.
  ];

  topology.self = {
    interfaces.eth0.network = "LAN";
    hardware.info = "RK3588S, 16GB (DDR4), Orange Pi 5, K8s Worker";
  };
}
