{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.devices;
in {
  options.atro.devices = {
    enable = mkEnableOption "boot basics";
    kernelModules = mkOption {
      type = types.listOf types.str;
      default = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    };
    kernelParams = mkOption {
      type = types.listOf types.str;
      default = ["ip=dhcp"];
    };
  };
}
