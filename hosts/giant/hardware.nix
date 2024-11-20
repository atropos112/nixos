_: {
  imports = [
    ../../lib/common/nvidia.nix
    ../../lib/modules/zfs
    ../../lib/modules/boot.nix
  ];

  atro.boot = {
    enable = true;
    # igc needed to be able to ssh at initrd time (for decryption)
    kernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "igc"];
    kernelParams = ["ip=dhcp"];
  };

  atro.hardware.zfs = {
    disks = {
      enable = true;
      hostId = "9676761a";
      netAtBootForDecryption = true;
      mainDriveId = "nvme-Samsung_SSD_980_PRO_1TB_S5GXNF1R901919N";
      mirrorDriveId = "nvme-Samsung_SSD_980_PRO_1TB_S5GXNL0W525668K";
    };
    impermanence.enable = true;
  };
}
