# =========================================================================
#      Orange Pi 5 Specific Configuration
# =========================================================================
{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  nixpkgs = inputs.nixpkgs-unstable;
  boardName = "orangepi5";
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  # NVME SECTION START
  # You will likely have to comment out this section if your nvme is not prepared so you can boot and preapre it.
  # Read the README.md for more information.
  fileSystems."/var/lib" = {
    device = "/dev/nvme0n1p1";
    fsType = "ext4";
    depends = [
      "/"
    ];
    # Without "nofail" it will not boot.
    options = [
      "nofail" # Do not fail to boot if this filesystem is not present
      "users" # Allow any user to mount
    ];
  };
  home-manager.users.root = {
    home = {
      sessionPath = [
        "/var/lib/rancher/k3s/data/current/bin"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/nvme0n1p2";
    }
  ];
  # NVME SECTION END

  boot = {
    # Some filesystems (e.g. zfs) have some trouble with cross (or with BSP kernels?) here.
    supportedFilesystems = lib.mkForce [
      "vfat"
      "fat32"
      "exfat"
      "ext4"
      "btrfs"
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = lib.mkForce ["dm_mod" "dm_crypt" "encrypted_keys"];
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];
  };

  sdImage = {
    inherit rootPartitionUUID;

    imageBaseName = "${boardName}-sd-image";
    compressImage = true;

    # install firmware into a separate partition: /boot/firmware
    populateFirmwareCommands = ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 1000; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
    '';
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  hardware = {
    opengl = {
      enable = true;
    };
    enableRedistributableFirmware = true;
  };
}
