{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
    ../../lib/modules/zfs
    ../../lib/modules/boot.nix
  ];

  # INFO: Surface doesn't play well with Pipewire not sure why.
  # Sadly the bluetooth support on pulse audio is very flimsy.
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
  services.pipewire.enable = false;

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
