_: let
  # ZFS not for longhorn
  filesystems = [
    "btrfs"
    "ext4"
    "zfs"
  ];
in {
  imports = [
    ../../lib/common/nvidia.nix
    ../../lib/common/kubernetes/amd64_hardware.nix
    ../../lib/pkgs/zfs.nix
  ];

  hardware.nvidia.powerManagement.enable = false;

  networking.hostId = "8f3bb97f";
  boot = {
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
    "/mnt/media" = {
      device = "hdd-pool/media";
      fsType = "zfs";
      options = ["X-mount.mkdir" "noatime"];
      neededForBoot = true;
    };
    "/mnt/media-yi" = {
      device = "hdd-pool/media-yi";
      fsType = "zfs";
      options = ["X-mount.mkdir" "noatime"];
      neededForBoot = true;
    };
    "/mnt/other" = {
      device = "hdd-pool/other";
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
