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
      /mnt/nfs  10.0.0.0/16(rw,no_subtree_check)

      /mnt/nfs  9.0.0.2(rw,no_subtree_check)
      /mnt/nfs  9.0.0.3(rw,no_subtree_check)
      /mnt/nfs  9.0.0.4(rw,no_subtree_check)
      /mnt/nfs  9.0.0.5(rw,no_subtree_check)
      /mnt/nfs  9.0.0.6(rw,no_subtree_check)
      /mnt/nfs  9.0.0.7(rw,no_subtree_check)
      /mnt/nfs  9.0.0.8(rw,no_subtree_check)
      /mnt/nfs  9.0.0.130(rw,no_subtree_check)

      /mnt/nfs  rzr(rw,no_subtree_check)
      /mnt/nfs  a21(rw,no_subtree_check)
      /mnt/nfs  smol(rw,no_subtree_check)
      /mnt/nfs  opi1(rw,no_subtree_check)
      /mnt/nfs  opi2(rw,no_subtree_check)
      /mnt/nfs  opi3(rw,no_subtree_check)
      /mnt/nfs  opi4(rw,no_subtree_check)
      /mnt/nfs  giant(rw,no_subtree_check)
    '';
  };
}
