_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
  ];
  networking.hostName = "atrorzr";
}
