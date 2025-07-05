{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.boot;
in {
  options.atro.boot = {
    enable = mkEnableOption "boot basics";
    kernelModules = mkOption {
      type = types.listOf types.str;
      default = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "zfs"];
    };
    kernelParams = mkOption {
      type = types.listOf types.str;
      default = ["ip=dhcp"];
    };
  };

  config = mkIf cfg.enable {
    boot = {
      inherit (cfg) kernelParams kernelModules;
      initrd = {
        inherit (cfg) kernelModules;
        availableKernelModules = cfg.kernelModules;
      };
    };
  };
}
