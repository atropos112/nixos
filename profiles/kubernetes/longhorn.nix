{
  config,
  pkgs,
  ...
}: {
  atro.boot.kernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "zfs" "dm_crypt"];

  environment.systemPackages = with pkgs; [
    openiscsi
    nfs-utils
    ipset
  ];

  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}";
  };

  system.activationScripts.usrlocalbin = ''
    mkdir -m 0755 -p /usr/local
    ln -nsf /run/current-system/sw/bin /usr/local/
  '';
}
