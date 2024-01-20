_: {
  imports = [
    ../../lib/common/nvidia.nix
    ../../lib/modules/zfs-root
    ../../lib/modules/boot.nix
  ];
  atro.hardware.zfs-root = {
    enable = true;
    hostId = "9676761a";
    bootDevices = ["nvme-Samsung_SSD_980_PRO_1TB_S5GXNL0W525668K" "nvme-Samsung_SSD_980_PRO_1TB_S5GXNF1R901919N"];
    netAtBootForDecryption = true;
  };

  atro.boot = {
    enable = true;
    kernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelParams = ["ip=dhcp"];
  };
}
