{lib, ...}: {
  imports = [
    ../../profiles/nvidia.nix
    ../../profiles/zfs
  ];
  hardware.nvidia.powerManagement.enable = false;

  # These disks do not coincide with the nodes lifecycle,
  # so formatting them with disko is not really appropriate.
  # As likely the node could be formatted but the disks would remain.
  fileSystems = {
    "/mnt/hdd" = {
      device = "hdd-pool";
      fsType = "zfs";
      options = ["X-mount.mkdir" "noatime"];
      neededForBoot = true;
    };
  };

  atro = {
    boot = {
      enable = true;
      kernelParams = lib.mkForce [
        "zfs.zfs_arc_max=6442450944" # 6G of max ARC
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      ];
    };

    diskoZfsRoot = {
      enable = true;
      mode = ""; # no mirroring as it only has one drive.
      hostId = "8425e349";
      drives = [
        "nvme-eui.0025385711b22693"
      ];
      encryption = {
        enable = false;
      };
    };
  };

  disko.devices.disk.longhorn = {
    type = "disk";
    device = "/dev/disk/by-id/ata-ST2000LM007-1R8174_ZDZTC50M";
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
