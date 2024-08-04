# =========================================================================
#      Orange Pi 5 Specific Configuration
# =========================================================================
{
  # WARN: Having tried 24-04 and unstable neither allowed the kernel to build, so I'm sticking with 23.11 for now.
  # Its also what https://github.com/ryan4yin/nixos-rk3588 is doing, once he changes can look to move as well.
  pkgs2311,
  config,
  inputs,
  lib,
  ...
}: let
  nixpkgs = inputs.nixpkgs2311;
  boardName = "orangepi5";
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
  pkgs = pkgs2311;
in {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

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
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };

    initrd.includeDefaultModules = lib.mkForce false;
    initrd.availableKernelModules = lib.mkForce [
      # NVMe
      "nvme"

      # SD cards and internal eMMC drives.
      "mmc_block"

      # Support USB keyboards, in case the boot fails and we only have
      # a USB keyboard, or for LUKS passphrase prompt.
      "hid"

      # For LUKS encrypted root partition.
      # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/luksroot.nix#L985
      "dm_mod" # for LVM & LUKS
      "dm_crypt" # for LUKS
      "input_leds"
    ];

    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./vendor_kernel.nix {});

    # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
    kernelParams = [
      "root=UUID=${rootPartitionUUID}"
      "rootwait"
      "rootfstype=ext4"

      "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
      "consoleblank=0" # disable console blanking(screen saver)
      "console=ttyS2,1500000" # serial port
      "console=tty1" # HDMI

      # docker optimizations
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];
  };

  # add some missing deviceTree in armbian/linux-rockchip:
  # orange pi 5's deviceTree in armbian/linux-rockchip:
  #    https://github.com/armbian/linux-rockchip/blob/rk-5.10-rkr4/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
  hardware = {
    deviceTree = {
      name = "rockchip/rk3588s-orangepi-5.dtb";
      overlays = [
        {
          # enable pcie2x1l2 (NVMe), disable sata0
          name = "orangepi5-sata-overlay";
          dtsText = ''
            // Orange Pi 5 Pcie M.2 to sata
            /dts-v1/;
            /plugin/;

            / {
              compatible = "rockchip,rk3588s-orangepi-5";

              fragment@0 {
                target = <&sata0>;

                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@1 {
                target = <&pcie2x1l2>;

                __overlay__ {
                  status = "okay";
                };
              };
            };
          '';
        }

        # enable i2c1
        {
          name = "orangepi5-i2c-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "rockchip,rk3588s-orangepi-5";

              fragment@0 {
                target = <&i2c1>;

                __overlay__ {
                  status = "okay";
                  pinctrl-names = "default";
                  pinctrl-0 = <&i2c1m2_xfer>;
                };
              };
            };
          '';
        }
      ];
    };

    graphics.package =
      (
        (pkgs.mesa.override {
          galliumDrivers = ["panfrost" "swrast"];
          vulkanDrivers = ["swrast"];
        })
        .overrideAttrs (_: {
          pname = "mesa-panfork";
          version = "23.0.0-panfork";
          src = pkgs.fetchFromGitLab {
            owner = "panfork";
            repo = "mesa";
            rev = "120202c675749c5ef81ae4c8cdc30019b4de08f4"; # branch: csf
            hash = "sha256-4eZHMiYS+sRDHNBtLZTA8ELZnLns7yT3USU5YQswxQ0=";
          };
        })
      )
      .drivers;

    enableRedistributableFirmware = lib.mkForce true;

    firmware = [
      (pkgs.callPackage ./firmware.nix {})
      (pkgs.callPackage ./mali-firmware.nix {})
    ];
  };
  powerManagement.cpuFreqGovernor = "ondemand";

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
    firmwareSize = 200; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
    '';
  };
}
