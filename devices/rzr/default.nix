_: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node_master.nix
    ../../lib/modules/kopia.nix
  ];
  networking.hostName = "atrorzr";

  atro.kopia = {
    enable = true;
    runAs = "root";
  };
}
