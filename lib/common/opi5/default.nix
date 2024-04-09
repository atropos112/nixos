_: {
  imports = [
    ../kubernetes/node_agent.nix
    ./hardware.nix # Non standard, typically this is done from devices/<devicename>/hardware.nix but its the same across and always should be so importing it here instead.
  ];

  topology.self = {
    interfaces.eth0.network = "LAN";
    hardware.info = "CPU: RK3588S, RAM: 16GB (DDR4), Make: Orange Pi 5, K8s: Worker";
  };
}
