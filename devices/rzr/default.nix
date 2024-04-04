_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];
  networking.hostName = "atrorzr";

  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
    acceleration = "cuda";
  };
}
