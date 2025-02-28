_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node.nix
    ../../lib/common/kubernetes/user.nix
    ../../lib/common/server
  ];

  atro.k3s.role = "server";

  topology.self = {
    name = "a21";
    interfaces = {
      tailscale0.addresses = ["100.93.148.41" "a21"];
      eth0.addresses = ["9.0.0.3"];
    };
    hardware.info = "i3-10100F, 32GB (DDR4), K8s Master";
  };

  networking = {
    hostName = "atroa21";
    interfaces.eth0.macAddress = "3c:7c:3f:0f:50:db";
  };
}
