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
      device = "/dev/disk/by-uuid/8551379f-cbef-4b8c-b4e8-5aacfd51b3f5";
      fsType = "ext4";
    };
    # That SSD is broken.
    # "/mnt/ssd2" = {
    #   device = "/dev/disk/by-uuid/b050f0b6-1fa2-406f-93bd-68efb241062e";
    #   fsType = "ext4";
    # };
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
