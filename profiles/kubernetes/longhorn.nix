{
  config,
  pkgs,
  ...
}: {
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
