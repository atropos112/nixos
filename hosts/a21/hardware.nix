_: {
  imports = [
    ../../profiles/common/amd64_hardware.nix
  ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d984a3cc-a32d-4fdf-997c-a69a9b1f9175";
      fsType = "ext4";
    };
    "/mnt/ssd1" = {
      device = "/dev/disk/by-uuid/7d378c7f-6732-499a-98da-a9ee7feba1e9";
      fsType = "ext4";
    };
    "/mnt/ssd2" = {
      device = "/dev/disk/by-uuid/d074aa4e-433c-40ff-a079-e719e079c4fc";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D09B-864F";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/8e92398e-7ce0-42c6-bf50-6d72b960ab6c";
    }
  ];
}
