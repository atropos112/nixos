_: {
  imports = [
    ../../lib/common/nvidia.nix
    ../../lib/modules/zfs
    ../../lib/modules/boot.nix
  ];

  atro.hardware.zfs = {
    disks = {
      enable = true;
      hostId = "9676761a";
      netAtBootForDecryption = true;
      mirrored = true;
    };
    impermanence.enable = true;
  };

  atro.boot = {
    enable = true;
    kernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelParams = ["ip=dhcp"];
  };
}
