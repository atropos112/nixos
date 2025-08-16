_: {
  imports = [
    ../../profiles/zfs.nix
  ];

  boot = {
    enable = true;
    kernelModules = ["phy_rockchip_naneng_combphy"];
  };

  swapDevices = [
    {
      device = "/persistent/swapfile";
      size = 16 * 1024;
    }
  ];
}
