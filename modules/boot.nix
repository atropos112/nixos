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
        # DEBUG MODE: Uncomment the line below if you're having boot issues
        #
        # Step 1: Enable debug mode by uncommenting this parameter:
        # "boot.shell_on_fail"
        #
        # Step 2: What this does:
        # - If boot fails during initrd stage, you'll be dropped into a root shell
        # - This allows you to investigate boot failures, check filesystems, etc.
        # - Useful for debugging ZFS mount issues, missing drives, or encryption problems
        #
        # Remember to comment it out again after debugging!
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
