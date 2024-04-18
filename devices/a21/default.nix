_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];

  topology.self = {
    name = "a21";
    interfaces = {
      tailscale0.addresses = ["100.93.148.41" "a21"];
      eth0.addresses = ["9.0.0.3"];
    };
    hardware.info = "i3-10100F, 32GB (DDR4), K8s Master";
  };

  networking.hostName = "atroa21";
}
