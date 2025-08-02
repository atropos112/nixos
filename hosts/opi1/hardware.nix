_: {
  atro = {
    boot = {
      enable = true;
      kernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
    };

    disko = {
      enable = true;
      hostId = "8f3cc91f";
      mode = ""; # no mirroring as it only has one drive.
      drives = [
        "nvme-CT1000P310SSD2_25205009A3D1"
      ];
      encryption = {
        enable = false;
      };
    };
  };
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-uuid/14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
  #     fsType = "ext4";
  #   };
  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/2178-694E";
  #     fsType = "vfat";
  #   };
  # };
}
