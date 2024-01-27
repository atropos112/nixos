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

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/nfs/longhorn  9.0.0.2(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.3(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.4(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.5(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.6(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.7(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.8(rw,no_subtree_check)
      /mnt/nfs/longhorn  9.0.0.130(rw,no_subtree_check)

      /mnt/nfs/longhorn  rzr(rw,no_subtree_check)
      /mnt/nfs/longhorn  a21(rw,no_subtree_check)
      /mnt/nfs/longhorn  smol(rw,no_subtree_check)
      /mnt/nfs/longhorn  opi1(rw,no_subtree_check)
      /mnt/nfs/longhorn  opi2(rw,no_subtree_check)
      /mnt/nfs/longhorn  opi3(rw,no_subtree_check)
      /mnt/nfs/longhorn  opi4(rw,no_subtree_check)
      /mnt/nfs/longhorn  giant(rw,no_subtree_check)
    '';
  };
}
