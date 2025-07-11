_: {
  imports = [
    ../../profiles/common/basic.nix
    ../../profiles/common/server.nix
    ../../profiles/kubernetes/server.nix
    ../../profiles/kubernetes/user.nix
    ./hardware.nix
  ];

  topology.self = {
    name = "smol";
    interfaces = {
      tailscale0.addresses = ["smol"];
      eth0.addresses = ["9.0.0.4"];
    };
    hardware.info = "i5-10210U, 16GB (DDR4), K8s Master";
  };

  networking = {
    hostName = "atrosmol";
    interfaces.eth0.macAddress = "2c:f0:5d:26:8d:da";
  };
}
