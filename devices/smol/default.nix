_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];

  topology.self = {
    name = "smol";
    interfaces.eth0.network = "LAN";
    hardware.info = "CPU: i5-10210U, RAM: 16GB (DDR4), K8s: Master";
  };

  networking.hostName = "atrosmol";
}
