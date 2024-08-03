{
  pkgs,
  lib,
  ...
}: {
  boot = {
    loader = {
      # NixOS wants to enable GRUB by default
      grub.enable = false;
      raspberryPi = {
        enable = true;

        # Set the version depending on your raspberry pi.
        version = 3;
        uboot.enable = true;

        # These two parameters are the important ones to get the
        # camera working. These will be appended to /boot/config.txt.
        firmwareConfig = ''
          start_x=1
          gpu_mem=256
        '';
      };
    };

    # Enables the generation of /boot/extlinux/extlinux.conf
    loader.generic-extlinux-compatible.enable = true;

    kernelPackages = pkgs.linuxPackages; # kernel version

    # Disable ZFS on kernel 6
    supportedFilesystems = lib.mkForce [
      "vfat"
      "xfs"
      "cifs"
      "ntfs"
    ];

    # forwarding
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv4.tcp_ecn" = true;
    };

    kernelParams = [
      "cma=320M"
    ];

    initrd.kernelModules = ["vc4" "bcm2835_dma" "i2c_bcm2835"];
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

  # Bit scary to have swap on an SD card, but it's not like we're going to be swapping a lot.
  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

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
