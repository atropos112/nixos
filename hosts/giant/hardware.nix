_: {
  imports = [
    ../../profiles/nvidia.nix
    ../../profiles/impermanence/desktop.nix
  ];

  atro = {
    boot = {
      enable = true;
      # igc needed to be able to ssh at initrd time (for decryption)
      kernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "igc"];
    };

    diskoZfsRoot = {
      enable = true;
      hostId = "9676761a";
      mode = "mirror";
      drives = [
        "nvme-Samsung_SSD_980_PRO_1TB_S5GXNF1R901919N"
        "nvme-Samsung_SSD_980_PRO_1TB_S5GXNL0W525668K"
      ];
      drivePartLabels = ["x" "y"];
      encryption = {
        enable = true;
        netAtBootForDecryption = {
          enable = true;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGqRdI3cwDuF/x1Hdr2AGmnNjTiU7hfXePqzlEMVn7F AtroGiant"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzyzsV64asxyikHArB1HNNMg2R9YGoepmpBnGzZjkE atropos@AtroSurface"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMBmA9QW6crCsDo49oB7wyD9oA0V4/BMZc1tf2qgH7q AtroRzr"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLyjGaUMq7SWWUXdew/+E213/KCUDB1D59iEOhE6gyB atropos@giant" # juiceSSH
          ];
          hostKey = "/persistent/netboot/key";
        };
      };
    };
  };
}
