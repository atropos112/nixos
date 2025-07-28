{pkgs, ...}: let
  filesystems = [
    "ext4"
  ];
in {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = filesystems;
    initrd = {
      supportedFilesystems = filesystems;
    };
  };
}
