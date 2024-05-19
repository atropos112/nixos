{lib, ...}: let
  mirrorBoot = idx: {
    type = "disk";
    device = "/dev/nvme${idx}n1";
    content = {
      type = "gpt";
      partitions = lib.mkForce {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot${idx}";
          };
        };
        swap = {
          size = "16G";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
in {
  imports = [
    # ../../lib/modules/zfs-root
    ../../lib/modules/boot.nix
  ];

  networking = {
    hostId = "8f3cc97f";
  };
  # atro.hardware.zfs-root = {
  #   enable = true;
  #   hostId = "8f3cc97f";
  #   bootDevices = ["nvme-BA_HFS256GD9TNG-62A0A_MI89N001212209B0R"];
  #   netAtBootForDecryption = false;
  # };

  atro.boot = {
    enable = true;
    kernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
  };

  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      x = mirrorBoot "0";
    };
    zpool = {
      zroot = {
        type = "zpool";
        # mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
          mountpoint = "none";
        };
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              #keylocation = "file:///tmp/secret.key";
              keylocation = "prompt";
            };
          };
          "root/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
            };
          };

          "root/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
            };
          };

          "root/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
            };
          };

          "root/persistent" = {
            type = "zfs_fs";
            mountpoint = "/persistent";
            options = {
              mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
