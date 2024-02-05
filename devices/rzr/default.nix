_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
    ../../lib/pkgs/attic-server.nix
  ];
  networking.hostName = "atrorzr";
}
