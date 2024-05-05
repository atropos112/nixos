_: {
  imports = [
    ../../lib/common/server/amd64_hardware.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e3162d61-e341-404f-b88c-a135f9a38829";
      fsType = "ext4";
    };
    "/mnt/ssd1" = {
      device = "/dev/disk/by-uuid/39a765c8-f391-4efc-b824-46dd0730e0bd";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8531-49E2";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/c9c0cb52-cb06-483d-b957-fd46d7893a70";
    }
  ];
}
