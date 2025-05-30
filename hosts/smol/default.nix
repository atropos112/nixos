_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node.nix
    ../../lib/common/kubernetes/user.nix
    ../../lib/common/server
  ];
  atro.k3s.role = "server";

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
