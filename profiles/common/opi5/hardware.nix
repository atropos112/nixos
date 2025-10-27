_: {
  imports = [
    ../../zfs
  ];

  atro = {
    boot = {
      enable = true;
      # Necessary otherwise kernel won't be able to load nvme at boot.
      kernelModules = ["phy_rockchip_naneng_combphy"];
    };

    diskoZfsRoot = {
      enable = true;
      mode = ""; # no mirroring as it only has one drive.
      encryption = {
        enable = false;
      };
    };
  };
}
