{inputs, ...}: let
  nixpkgs = inputs.nixpkgs-unstable;
  pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgsCross.aarch64-multiplatform;

  bootloaderSubpath = "/u-boot-sunxi-with-spl.bin";
  filesystems = pkgs.lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
    /*
    "zfs"
    */
    "ext4"
    "vfat"
  ];
  bootloaderPackage = pkgs.ubootOrangePiZero2;
  # Build unstable kernel
  kernel = with pkgs;
  with lib;
    buildLinux rec {
      kernelPatches = [
        linuxKernel.kernelPatches.bridge_stp_helper
        linuxKernel.kernelPatches.request_key_helper
      ];
      src = fetchGit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
        rev = "33cc938e65a98f1d29d0a18403dbbee050dcad9a";
      };
      version = "6.7.0-rc4";
      modDirVersion = version;
      extraMeta.branch = versions.majorMinor version;
    };
in {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  boot = {
    kernelPackages = pkgs.linuxPackagesFor kernel;
    supportedFilesystems = filesystems;
    initrd.supportedFilesystems = filesystems;
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];
  };
  hardware.deviceTree = {
    enable = true;
    filter = "sun50i-h616-orangepi-zero2.dtb";
    overlays = [
      {
        name = "sun50i-h616-orangepi-zero2.dtb";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "xunlong,orangepi-zero2", "allwinner,sun50i-h616";
          };

          &ehci0 {
            status = "okay";
          };

          &ehci1 {
            status = "okay";
          };

          &ehci2 {
            status = "okay";
          };

          &ehci3 {
            status = "okay";
          };

          &ohci0 {
            status = "okay";
          };

          &ohci1 {
            status = "okay";
          };

          &ohci2 {
            status = "okay";
          };

          &ohci3 {
            status = "okay";
          };
        '';
      }
    ];
  };

  sdImage = {
    postBuildCommands = ''
      # Emplace bootloader to specific place in firmware file
      dd if=${bootloaderPackage}${bootloaderSubpath} of=$img    \
        bs=8 seek=1024                                          \
        conv=notrunc # prevent truncation of image
    '';
    compressImage = true;
  };
}
