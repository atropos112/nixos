_: {
  imports = [
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
        "nvme-CT500P3PSSD8_2333E86D866C"
      ];
      encryption = {
        enable = false;
      };
    };
  };

  disko.devices.disk.longhorn = {
    type = "disk";
    device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S754NX0Y415705P";
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
