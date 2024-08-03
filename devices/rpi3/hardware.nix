{
  pkgs,
  lib,
  ...
}: {
  boot = {
    # NixOS wants to enable GRUB by default
    loader.grub.enable = false;

    kernelPackages = pkgs.linuxPackages; # kernel version

    # Enables the generation of /boot/extlinux/extlinux.conf
    loader.generic-extlinux-compatible.enable = true;

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

    # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
    # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
    # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
    kernelParams = ["cma=256M"];
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
