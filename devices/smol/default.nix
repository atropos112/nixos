_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];

  topology.self = {
    name = "smol";
    interfaces = {
      tailscale0.addresses = ["100.121.127.11" "smol"];
      eth0.addresses = ["9.0.0.4"];
    };
    hardware.info = "i5-10210U, 16GB (DDR4), K8s Master";
  };

  networking.hostName = "atrosmol";
}
