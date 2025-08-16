_: {
  imports = [
    ../../zfs.nix
  ];

  atro.boot = {
    enable = true;
    kernelModules = ["phy_rockchip_naneng_combphy"];
  };
}
