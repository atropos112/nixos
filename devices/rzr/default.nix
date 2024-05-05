_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node.nix
    ../../lib/common/kubernetes/user.nix
    ../../lib/modules/kopia.nix
  ];

  atro.k3s.role = "server";

  atro.kopia = {
    enable = true;
    runAs = "root";
  };

  topology.self = {
    name = "rzr";
    interfaces = {
      tailscale0.addresses = ["100.120.250.58" "rzr"];
      eth0.addresses = ["9.0.0.2"];
    };
    hardware.info = "i7-6900K, 32GB (DDR4), GTX1080Ti, K8s Master";
  };

  networking.hostName = "atrorzr";

  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
    acceleration = "cuda";
  };
}
