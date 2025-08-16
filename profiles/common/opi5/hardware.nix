_: {
  imports = [
    ../../zfs.nix
  ];

  atro = {
    boot = {
      enable = true;
      # Necessary otherwise kernel won't be able to load nvme at boot.
      kernelModules = ["phy_rockchip_naneng_combphy"];
    };

    disko = {
      enable = true;
      mode = ""; # no mirroring as it only has one drive.
      encryption = {
        enable = false;
      };
    };
  };
}
