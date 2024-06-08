_: {
  imports = [
    ../../lib/modules/zfs
    ../../lib/modules/boot.nix
  ];

  atro.hardware.zfs = {
    disks = {
      enable = true;
      hostId = "8f3cc97f";
      netAtBootForDecryption = false;
      mainDriveId = "nvme-BA_HFS256GD9TNG-62A0A_MI89N001212209B0R";
    };
    impermanence.enable = true;
  };

  atro.boot = {
    enable = true;
    kernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
  };
}
