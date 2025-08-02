_: {
  atro = {
    boot = {
      enable = true;
      kernelModules = [];
    };

    disko = {
      enable = true;
      hostId = "8f3cc91f";
      mode = ""; # no mirroring as it only has one drive.
      drives = [
        "nvme-KBG40ZNS256G_NVMe_KIOXIA_256GB_313PD383QL42"
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
