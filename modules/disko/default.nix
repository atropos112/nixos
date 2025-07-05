/*
This module configures disko to use zfs as root with mirrored boot partitions.
It makes assumption that all drives are equally sized and are to be used equally.

The fact I use N copies of boot partitions is somewhat opinionated, it is few GBs of space
that I am willing to waste on redundancy and simplicity.
*/
{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types length mod unique filter tail imap0 head optionalAttrs;
  cfg = config.atro.hardware.zfs.disks;
  diskCfg = bootName: id: {
    type = "disk";
    device = "/dev/disk/by-id/${id}";
    content = {
      type = "gpt";
      partitions = {
        MBR = {
          type = "EF02"; # for grub MBR
          size = "1M";
          priority = 1; # Needs to be first partition
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/${bootName}";
            mountOptions = ["nofail"];
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

  dataSetOptions =
    {
      mountpoint = "none";
    }
    // optionalAttrs cfg.encrypted {
      encryption = "aes-256-gcm";
      keyformat = "passphrase";
      keylocation = "prompt";
    };
in {
  options.atro.hardware.zfs.disks = {
    enable = mkEnableOption "zfs as root";
    hostId = mkOption {
      type = types.str;
      desciption = ''
        The host id of the machine, used to identify the disks.
        It doesn't realy matter what it is as long as it remains the same.
        That is, once you set it for a machine, you can't change it unless you reinstall the machine
        by formatting the disks and reinstalling nixos.
      '';
    };
    drives = mkOption {
      description = ''
        Drive ids of the disks.
        Here drive id refers to the id of the drive in /dev/disk/by-id.

        Every drive will be given a boot partition and a zfs partition.
        Boot partition is replicated to form a redundancy.

        The first drive's boot partition will be used as the main boot partition.
        Then the next ones will be used as mirrored boot partitions.

        Strictly speaking you do not need n-1 backups for boot. But in order to have same amount of
        storage across the drives for zfs you kind of have to "waste" that space otherwise so might
        as well.
      '';
      type = types.listOf types.str;
    };
    mode = mkOption {
      description = ''
        The mode of the zpool. Such as mirror, raidz1, raidz2, raidz3.
        Set to empty string to use single drive mode.

        Note using stripped mode with multiple drives is not supported.
      '';
      type = types.enum [
        ""
        "mirror"
        "raidz1"
        "raidz2"
        "raidz3"
      ];
    };

    encryption = {
      enable = mkEnableOption "Encrypt the zfs root dataset.";
      netAtBootForDecryption = {
        enable = mkEnableOption "Connect to internet at boot to allow decryption over network.";
        authorizedKeys = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            The authorized keys to be added to the root user's authorized_keys file.
            This is useful for decrypting the root dataset over network.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.encryption.enable || !cfg.encryption.netAtBootForDecryption.enable;
        message = "Encryption must be enabled if you want to use netAtBootForDecryption.";
      }
      {
        assertion = !cfg.encryption.netAtBootForDecryption.enable || (length cfg.encryption.netAtBootForDecryption.authorizedKeys) > 0;
        message = "You must have at least one authorized key to use netAtBootForDecryption.";
      }
      {
        # If more than one drive mode must not be set to ""
        assertion = (length cfg.drives) == 1 || cfg.mode != "";
        message = "Stripped mode is not supported with multiple drives.";
      }
      {
        # If mirror mode is used then the number of drives must be even.
        assertion = (length cfg.drives) mod 2 == 0 || cfg.mode != "mirror";
        message = "You must have an even number of drives to use mirror mode.";
      }
      {
        # If raidz1 mode is used then the number of drives must be greater than 4.
        assertion = length cfg.drives > 4 || cfg.mode != "raidz1";
        message = "You must have more than 4 drives to use raidz1 mode.";
      }
      {
        # If raidz2 mode is used then the number of drives must be greater than 6.
        assertion = length cfg.drives > 6 || cfg.mode != "raidz2";
        message = "You must have more than 6 drives to use raidz2 mode.";
      }
      {
        # If raidz3 mode is used then the number of drives must be greater than 8.
        assertion = length cfg.drives > 8 || cfg.mode != "raidz3";
        message = "You must have more than 8 drives to use raidz3 mode.";
      }
      {
        # hostId must be non empty
        assertion = length cfg.hostId > 0;
        message = "hostId must be bigger than 1 character.";
      }
      {
        # Drive ids must be unique
        assertion = length cfg.drives == length (unique cfg.drives);
        message = "Drive ids must be unique.";
      }
      {
        # All drives must be non empty
        assertion = length cfg.drives == length (filter (id: id != "") cfg.drives);
        message = "Drive ids must be non empty.";
      }
    ];

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
          device = "nodev";
          zfsSupport = true;
          efiInstallAsRemovable = true;
        };
      };
    };

    # We only need to do mirrored boot on the drives other than the first drive.
    # The first drive is the main boot drive and is passed as boot partition elsewhere.
    boot.loader.grub.mirroredBoots =
      cfg.drives
      |> tail # If only one drive then this will be empty list
      |> imap0 (i: driveId: {
        path = "/boot-fallback-${i}";
        devices = "/dev/disk/by-id/${driveId}";
      });

    fileSystems."/persistent".neededForBoot = true;

    disko.devices = {
      disk =
        # First drive is keyd as x, the rest are keyed as y0, y1, y2, etc.
        # Matching the /boot-fallback-N for mirrored boot drives and /boot for the main boot drive.
        {x = cfg.drives |> head |> diskCfg "boot";}
        // (cfg.drives
          |> tail
          |> imap0 (i: driveId: {
            "y${i}" = diskCfg "boot-fallback-${i}" driveId;
          }));
      zpool = {
        zroot = {
          type = "zpool";
          mode = cfg.mode;
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
              options = dataSetOptions;
            };
            "nixos/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
              postCreateHook = ''
                zfs snapshot zroot/nixos/root@blank
                zfs hold -r keep zroot/nixos/root@blank
              '';
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

              postCreateHook = ''
                zfs snapshot zroot/nixos/home@blank
                zfs hold -r keep zroot/nixos/home@blank
              '';
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
    boot.initrd.network = mkIf cfg.netAtBootForDecryption {
      enable = true;
      postCommands = ''
        tee -a /root/.profile >/dev/null <<EOF
        if zfs load-key zroot/nixos; then
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
          # WARN: Providing path directly via ./notSoPrivatePrivateKey DOES NOT WORK, it fails on new machine installs.
          "/persistent/netboot/key"
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
}
