_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];

  topology.self = {
    name = "a21";
    interfaces.eth0.network = "LAN";
    hardware.info = "CPU: i3-10100F, RAM: 32GB (DDR4), K8s: Master";
  };

  networking.hostName = "atroa21";
}
