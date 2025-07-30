{pkgs, ...}: let
  filesystems = [
    "ext4"
    "zfs"
  ];
in {
  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = filesystems;
    initrd = {
      supportedFilesystems = filesystems;
    };
  };
}
