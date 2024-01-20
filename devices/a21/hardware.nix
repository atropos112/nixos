_: {
  imports = [
    ../../lib/common/kubernetes/amd64_hardware.nix
  ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0ae04819-e465-4058-ac8d-09c4be8eff99";
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
      device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/af4be6bd-39a8-48a0-ad1e-e6c3338866f4";
    }
  ];
}
