_: {
  imports = [
    ../../profiles/zfs.nix
  ];
  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];
  # boot.initrd.availableKernelModules = ["phy_rockchip_naneng_combphy"];
}
