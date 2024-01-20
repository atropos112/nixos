_: {
  imports = [
    ../../lib/modules/zfs-root
    ../../lib/modules/boot.nix
  ];
  atro.hardware.zfs-root = {
    enable = true;
    hostId = "8f3cc97f";
    bootDevices = ["nvme-BA_HFS256GD9TNG-62A0A_MI89N001212209B0R"];
    netAtBootForDecryption = false;
  };

  atro.boot = {
    enable = true;
    kernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
  };
}
