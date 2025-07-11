{lib, ...}: let
  # ZFS not for longhorn
  filesystems = [
    "btrfs"
    "ext4"
    "zfs"
  ];
in {
  imports = [
    ../../profiles/common/amd64_hardware.nix
    ../../profiles/nvidia.nix
    ../../profiles/zfs.nix
  ];
  hardware.nvidia.powerManagement.enable = false;

  networking.hostId = "8f3bb97f";
  boot = {
    kernelParams = lib.mkForce [
      "zfs.zfs_arc_max=6442450944" # 6G of max ARC
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    supportedFilesystems = filesystems;
    initrd = {
      supportedFilesystems = filesystems;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1ef1fd8f-cac7-4a40-9aef-d8da0e31974d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D200-23B4";
      fsType = "vfat";
    };
    "/mnt" = {
      device = "hdd-pool";
      fsType = "zfs";
      options = ["X-mount.mkdir" "noatime"];
      neededForBoot = true;
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/d2c0823a-d1a4-41a5-9853-6e1ba073841d";
    }
  ];
}
