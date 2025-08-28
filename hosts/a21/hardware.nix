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
        "nvme-CT500P3PSSD8_2333E86D866C"
      ];
      encryption = {
        enable = false;
      };
    };
  };

  disko.devices.disk.longhorn = {
    type = "disk";
    device = "/dev/disk/by-id/ata-ST2000LM007-1R8174_ZDZTCS7D";
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
