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
}
