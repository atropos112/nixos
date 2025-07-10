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
      default = [
        "ip=dhcp"
        # WARN: If you are in trouble, not being able to pass initrd stage you ca uncomment the
        # line bellow to allow you to drop into a shell and investigate.
        # Please do uncomment it once you are done debugging as it is a security risk.
        # It is a security risk as it allows anyone to drop into a shell as root, no password needed.
        #
        # "boot.shell_on_fail" # Allows you to drop in a shell if booting fails in initrd
      ];
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
