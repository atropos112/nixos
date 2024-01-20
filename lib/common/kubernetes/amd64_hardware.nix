{
  pkgs,
  lib,
  ...
}: let
  # ZFS not for longhorn
  filesystems = [
    "btrfs"
    "ext4"
  ];
in {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    supportedFilesystems = filesystems;
    initrd = {
      supportedFilesystems = filesystems;
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
  };
}
