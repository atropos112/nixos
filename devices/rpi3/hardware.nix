{
  lib,
  pkgs,
  ...
}: {
  boot = {
    supportedFilesystems = lib.mkForce [
      "vfat"
      "fat32"
      "exfat"
      "ext4"
      "btrfs"
    ];

    loader = {
      # NixOS wants to enable GRUB by default
      grub.enable = false;

      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;

    # Disable ZFS on kernel 6

    # forwarding
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv4.tcp_ecn" = true;
    };

    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
  };

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    # Prior to 19.09, the boot partition was hosted on the smaller first partition
    # Starting with 19.09, the /boot folder is on the main bigger partition.
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [pkgs.wireless-regdb];
  };

  # Networking
  networking = {
    useDHCP = true;

    # Enabling WIFI
    wireless = {
      enable = true;
      interfaces = ["wlan0"];
      networks."AtroNet24" = {
        # INFO: got this by running `wpa_passphrase AtroNet24 <password>`
        pskRaw = "13b2ded64aa9e38924913401fea407da00e871eafd1e97be4ecdac0c24b92d1f";
      };
    };
  };
}
