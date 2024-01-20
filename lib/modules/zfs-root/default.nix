{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.atro.hardware.zfs-root;
  efiSystemPartitions = map (diskName: diskName + cfg.partitionScheme.efiBoot) cfg.bootDevices;
  swapPartitions = map (diskName: diskName + cfg.partitionScheme.swap) cfg.bootDevices;
in {
  options.atro.hardware.zfs-root = {
    enable = mkEnableOption "zfs as root";
    bootDevices = mkOption {
      type = types.listOf types.str;
      # No default value, because we want to force the user to specify.
    };
    devNodes = mkOption {
      type = types.str;
      default = "/dev/disk/by-id/";
    };
    partitionScheme = mkOption {
      type = types.attrsOf types.str;
      default = {
        biosBoot = "-part5";
        efiBoot = "-part1";
        swap = "-part4";
        bootPool = "-part2";
        rootPool = "-part3";
      };
    };
    dataSets = mkOption {
      type = types.attrsOf types.str;
      default = {
        "rpool/nixos/home" = "/home";
        "rpool/nixos/var/lib" = "/var/lib";
        "rpool/nixos/var/log" = "/var/log";
        "rpool/nixos/root" = "/";
        "bpool/nixos/root" = "/boot";
      };
    };
    hostId = mkOption {
      type = types.str;
    };
    netAtBootForDecryption = mkEnableOption "Connect to internet at boot to allow decryption over network.";
  };

  config = mkIf cfg.enable {
    networking = {
      inherit (cfg) hostId;
    };

    fileSystems = mkMerge (mapAttrsToList
      (dataset: mountpoint: {
        "${mountpoint}" = {
          device = "${dataset}";
          fsType = "zfs";
          options = ["X-mount.mkdir" "noatime"];
          neededForBoot = true;
        };
      })
      cfg.dataSets
      ++ map
      (esp: {
        "/boot/efis/${esp}" = {
          device = "${cfg.devNodes}${esp}";
          fsType = "vfat";
          options = [
            "x-systemd.idle-timeout=1min"
            "x-systemd.automount"
            "noauto"
            "nofail"
            "noatime"
            "X-mount.mkdir"
          ];
        };
      })
      efiSystemPartitions);

    swapDevices =
      map
      (swap: {
        device = "${cfg.devNodes}${swap}";
        discardPolicy = "both";
        randomEncryption = {
          enable = true;
          allowDiscards = true;
        };
      })
      swapPartitions;

    boot = {
      supportedFilesystems = ["zfs"];
      zfs = {
        inherit (cfg) devNodes;
      };
      loader = {
        generationsDir.copyKernels = true;
        efi = {
          canTouchEfiVariables = false;
          efiSysMountPoint =
            "/boot/efis/"
            + (head cfg.bootDevices)
            + cfg.partitionScheme.efiBoot;
        };
        grub = {
          enable = true;
          useOSProber = true;
          copyKernels = true;
          efiSupport = true;
          zfsSupport = true;
          efiInstallAsRemovable = true;
          devices = map (diskName: cfg.devNodes + diskName) cfg.bootDevices;
          extraInstallCommands = toString (map
            (diskName: ''
              set -x
              ${pkgs.coreutils-full}/bin/cp -r ${config.boot.loader.efi.efiSysMountPoint}/EFI /boot/efis/${diskName}${cfg.partitionScheme.efiBoot}
              set +x
            '')
            (tail cfg.bootDevices));
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
