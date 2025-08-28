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
      hostId = "5d1fb93f";
      drives = [
        "nvme-eui.0026b7684236be05"
      ];
      encryption = {
        enable = false;
      };
    };
  };

  disko.devices.disk.longhorn = {
    type = "disk";
    device = "/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S30YJ9JH412739";
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
