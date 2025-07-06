_: {
  imports = [
    ../../lib/common
    ./hardware.nix
    ../../profiles/kubernetes/server.nix
    ../../profiles/kubernetes/user.nix
    ../../lib/common/server
  ];

  topology.self = {
    name = "a21";
    interfaces = {
      tailscale0.addresses = ["a21"];
      eth0.addresses = ["9.0.0.3"];
    };
    hardware.info = "i3-10100F, 32GB (DDR4), K8s Master";
  };

  networking = {
    hostName = "atroa21";
    interfaces.eth0.macAddress = "3c:7c:3f:0f:50:db";
  };
}
