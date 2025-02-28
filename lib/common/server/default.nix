{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  shortHostName =
    if builtins.substring 0 4 hostName == "atro"
    then builtins.substring 4 (builtins.stringLength hostName) hostName
    else hostName;
in {
  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
  environment.systemPackages = with pkgs; [
    ethtool
    networkd-dispatcher
  ];

  # This clashse with networking.useDHCP but is needed for the optimisations below.
  # systemd.network = {
  #   enable = true;
  # };
  #

  # This is needed to improve perf of advertised routes
  # services.networkd-dispatcher = {
  #   enable = true;
  #   rules."50-tailscale" = {
  #     onState = ["routable"];
  #     script = ''
  #       #!${pkgs.runtimeShell}
  #       NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")
  #       ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
  #       exit 0
  #     '';
  #   };
  # };

  # Disabling as i don't use exit nodes AND the advertise-routes flag is not reliable
  # services = {
  #   # vpn mesh to connect to other devices
  #   tailscale = {
  #     interfaceName = "tailscale0"; # Default
  #     extraUpFlags = lib.mkForce [
  #       # WARN: Tried using advertise-routes but it cuts off at times
  #       "--advertise-routes=9.0.0.128/25,9.0.0.64/26,9.0.0.32/27,9.0.0.1/32"
  #       "--advertise-exit-node"
  #       "--accept-routes"
  #       "--hostname=${shortHostName}"
  #     ];
  #   };
  # };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
