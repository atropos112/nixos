_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];

  topology.self = {
    name = "rzr";
    interfaces.eth0.network = "LAN";
    hardware.info = "CPU: i7-6900K, RAM: 32GB (DDR4), GPU: GTX1080Ti, K8s: Master";
  };

  networking.hostName = "atrorzr";

  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
    acceleration = "cuda";
  };
}
