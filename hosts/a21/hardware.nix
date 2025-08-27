_: {
  imports = [
    ../../profiles/common/amd64_hardware.nix
    ../../profiles/zfs.nix
  ];

  atro = {
    boot = {
      enable = true;
    };

    diskoZfsRoot = {
      enable = true;
      mode = ""; # no mirroring as it only has one drive.
      hostId = "8f5bb92f";
      drives = [
        "TBD-INTERNAL-NVME"
      ];
      encryption = {
        enable = false;
      };
    };
  };

  disko.devices.disk.longhorn = {
    type = "disk";
    device = "TBD-EXTERNAL-SSD";
    content = {
      type = "gpt";
      partitions.longhorn = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/longhorn";
        };
      };
    };
  };
}
