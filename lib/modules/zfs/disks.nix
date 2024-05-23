{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.hardware.zfs.disks;
  diskCfg = idx: {
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
            priority = 100;
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
  options.atro.hardware.zfs.disks = {
    enable = mkEnableOption "zfs as root";
    hostId = mkOption {
      type = types.str;
    };
    mirrored = mkEnableOption "mirror the boot partition";
    netAtBootForDecryption = mkEnableOption "Connect to internet at boot to allow decryption over network.";
  };

  config = mkIf cfg.enable {
    networking = {
      inherit (cfg) hostId;
    };
    boot = {
      supportedFilesystems = ["zfs"];
      loader = {
        generationsDir.copyKernels = true;
        efi = {
          canTouchEfiVariables = false;
        };
        grub = {
          enable = true;
          useOSProber = true;
          copyKernels = true;
          efiSupport = true;
          zfsSupport = true;
          efiInstallAsRemovable = true;
        };
      };
    };

    boot.loader.grub.mirroredBoots =
      if cfg.mirrored
      then [
        {
          path = "/boot0";
          devices = ["nodev"];
        }
        {
          path = "/boot1";
          devices = ["nodev"];
        }
      ]
      else [
        {
          path = "/boot0";
          devices = ["nodev"];
        }
      ];

    fileSystems."/persistent".neededForBoot = true;

    disko.devices = {
      disk =
        if cfg.mirrored
        then {
          x = diskCfg "0";
          y = diskCfg "1";
        }
        else {
          x = diskCfg "0";
        };
      zpool = {
        zroot = {
          type = "zpool";
          mode =
            if cfg.mirrored
            then "mirror"
            else "";
          rootFsOptions = {
            compression = "lz4";
            acltype = "posixacl";
            xattr = "sa";
            "com.sun:auto-snapshot" = "true";
            mountpoint = "none";
          };
          datasets = {
            "nixos" = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                encryption = "aes-256-gcm";
                keyformat = "passphrase";
                keylocation = "prompt";
              };
            };
            "nixos/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
              postCreateHook = "zfs snapshot zroot/nixos/root@blank";
            };

            "nixos/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
            };

            "nixos/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };

              postCreateHook = "zfs snapshot zroot/nixos/home@blank";
            };

            "nixos/persistent" = {
              type = "zfs_fs";
              mountpoint = "/persistent";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "true";
              };
            };
          };
        };
      };
    };

    # Those are not keys used anywhere other than to be able to ssh to machine on boot.
    # They are insecure by default as they are accessible at boot, anyone with physical access to the PC has access to these keys.
    boot.initrd = mkIf cfg.netAtBootForDecryption {
      kernelModules = mkIf cfg.netAtBootForDecryption [
        "igc"
      ];
      network = {
        enable = true;
        postCommands = ''
          tee -a /root/.profile >/dev/null <<EOF
          if zfs load-key rpool/nixos; then
              pkill zfs
          fi
          exit
          EOF'';
        ssh = {
          enable = true;
          # To prevent ssh clients from freaking out because a different host key is used,
          # a different port for ssh is useful (assuming the same host has also a regular sshd running)
          port = 2222;
          # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
          # the keys are copied to initrd from the path specified; multiple keys can be set
          # you can generate any number of host keys using
          # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`

          # I wanted to make this a secret using sops-nix sadly this file is copied before the /run/secrets are available so it's not possible
          hostKeys = [
            ./notSoPrivatePrivateKey
          ];

          # public ssh key used for login
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGqRdI3cwDuF/x1Hdr2AGmnNjTiU7hfXePqzlEMVn7F AtroGiant"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzyzsV64asxyikHArB1HNNMg2R9YGoepmpBnGzZjkE atropos@AtroSurface"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMBmA9QW6crCsDo49oB7wyD9oA0V4/BMZc1tf2qgH7q AtroRzr"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLyjGaUMq7SWWUXdew/+E213/KCUDB1D59iEOhE6gyB atropos@giant" # juiceSSH
          ];
        };
      };
    };
  };
}
