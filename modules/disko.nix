/*
This module configures disko to use zfs as root with mirrored boot partitions.
It makes assumption that all drives are equally sized and are to be used equally.

The fact I use N copies of boot partitions is somewhat opinionated, it is few GBs of space
that I am willing to waste on redundancy and simplicity.
*/
{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types length mod unique filter tail imap1 head optionalAttrs listToAttrs imap0;
  inherit (builtins) toString stringLength elemAt;
  cfg = config.atro.disko;
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
    // optionalAttrs cfg.encryption.enable {
      encryption = "aes-256-gcm";
      keyformat = "passphrase";
      keylocation = "prompt";
    };

  bootDirName = i:
    if i == 0
    then "boot"
    else "boot-fallback-${toString i}";

  # Effectively this is going to be x0, x1, x2, ...
  # uless user provides labels for the drives, which they might have to for compatibility reasons.
  diskLabels =
    if cfg.drivePartLabels != null
    then cfg.drivePartLabels
    else (cfg.drives |> imap0 (i: _: "x${toString i}"));

  # This will look like:
  # {
  # "<label-0>" = diskCfg "boot" "<disk-id-0>"
  # "<label-1>" = diskCfg "boot-fallback-1" "<disk-id-1>"
  # "<label-2>" = diskCfg "boot-fallback-2" "<disk-id-2>"
  # }
  #
  # Where labels could would be x0, x1, x2 unless user provided labels.
  disks =
    {"${elemAt diskLabels 0}" = cfg.drives |> head |> diskCfg (bootDirName 0);}
    // (
      cfg.drives
      |> tail
      |> imap1 (i: driveId: {
        name = elemAt diskLabels i;
        value = diskCfg (bootDirName i) driveId;
      })
      |> listToAttrs
    );
in {
  imports = [
    inputs.disko.nixosModules.disko # Is used within some modules not necessarily used though.
  ];

  options.atro.disko = {
    enable = mkEnableOption "zfs as root";
    hostId = mkOption {
      type = types.str;
      description = ''
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
    drivePartLabels = mkOption {
      description = ''
        The labels to use for the drives.
        This is used to identify the drives in the boot loader.
        If not set will use x0, x1, x2, ... for the first drive, second drive, etc.
      '';
      type = types.nullOr (types.listOf types.str);
      default = null;
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
        hostKey = mkOption {
          type = types.str;
          default = "";
          description = ''
            The path to the host key used by initrd to communicate with whoever is trying to connect to the machine.

            Warning: This is not a secret, it can be seen by anyone with access to the machine.
            And that is fine because all it is saying is to the machine connecting "I am indeed the machine you thought I was".
            And most importantly, not the other way around, the connecting machine still needs to have private key that matches
            the public key in the authorizedKeys, this is not a security flaw.

            Warning: The secret can't be passed through sops-nix or /nix/store it has to be in the path that exists at boot.
            It can't be as a sops-nix secret because initrd needs it before sops-nix is available.
            It can't be in /nix/store because on the first boot the machine will not have it in the store.
            Thas has to be a path like `/persistent/netboot/key` nothing fancy sadly.
          '';
        };
        authorizedKeys = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            The authorized keys to be added to the root user's authorized_keys file.
            This is useful for decrypting the root dataset over network.
          '';
        };
        sshPort = mkOption {
          type = types.int;
          default = 2222;
          description = ''
            The port to use for ssh.

            You likely want it to be something other than 22 as you will have "host has changed" errors
            if you try to connect to initrd on 22 and then to the machine on 22 also.
            To avoid that use a different port.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        # If encryption is enabled then netAtBootForDecryption must be enabled.
        assertion = cfg.encryption.enable || !cfg.encryption.netAtBootForDecryption.enable;
        message = "Encryption must be enabled if you want to use netAtBootForDecryption.";
      }
      {
        # If netAtBootForDecryption is enabled then it must have at least one authorized key.
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
        assertion = (mod (length cfg.drives) 2) == 0 || cfg.mode != "mirror";
        message = "You must have an even number of drives to use mirror mode.";
      }
      {
        # If raidz1 mode is used then the number of drives must be greater than 4.
        assertion = length cfg.drives >= 4 || cfg.mode != "raidz1";
        message = "You must have at least 4 drives to use raidz1 mode.";
      }
      {
        # If raidz2 mode is used then the number of drives must be greater than 6.
        assertion = length cfg.drives >= 6 || cfg.mode != "raidz2";
        message = "You must have at least 6 drives to use raidz2 mode.";
      }
      {
        # If raidz3 mode is used then the number of drives must be greater than 8.
        assertion = length cfg.drives >= 8 || cfg.mode != "raidz3";
        message = "You must have at least 8 drives to use raidz3 mode.";
      }
      {
        # hostId must be non empty
        assertion = stringLength cfg.hostId > 0;
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
      {
        # If drivePartLabels are not null then they must be unique
        assertion = cfg.drivePartLabels == null || length cfg.drivePartLabels == length (unique cfg.drivePartLabels);
        message = "Drive part labels must be unique.";
      }
      {
        # If drivePartLabels are not null then they must be the same length as drives
        assertion = cfg.drivePartLabels == null || length cfg.drivePartLabels == length cfg.drives;
        message = "Drive part labels must be the same length as drives.";
      }
    ];

    networking = {
      inherit (cfg) hostId;
    };
    boot = {
      supportedFilesystems.zfs = true;
      initrd.supportedFilesystems.zfs = true;
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
      |> imap1 (i: driveId: {
        path = "/${bootDirName i}";
        devices = ["/dev/disk/by-id/${driveId}"];
      });

    fileSystems."/persistent".neededForBoot = true;

    disko.devices = {
      disk = disks;
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
    boot.initrd.network = mkIf cfg.encryption.netAtBootForDecryption.enable {
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
        port = cfg.encryption.netAtBootForDecryption.sshPort;
        # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
        # the keys are copied to initrd from the path specified; multiple keys can be set
        # you can generate any number of host keys using
        # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`

        # I wanted to make this a secret using sops-nix sadly this file is copied before the /run/secrets are available so it's not possible
        hostKeys = [
          # WARN: Providing path directly via ./notSoPrivatePrivateKey DOES NOT WORK, it fails on new machine installs.
          cfg.encryption.netAtBootForDecryption.hostKey
        ];

        # public ssh key used for login
        authorizedKeys = cfg.encryption.netAtBootForDecryption.authorizedKeys;
      };
    };
  };
}
