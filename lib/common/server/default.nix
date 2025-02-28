{
  config,
  lib,
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

  services = {
    # vpn mesh to connect to other devices
    tailscale = {
      useRoutingFeatures = "both";
      extraUpFlags = lib.mkForce [
        # WARN: Ensuring that the nodes that the server nodes are not in the routes being shared.
        # This means all server nodes need to be in (9.0.0.1, 9.0.0.32)
        # 9.0.0.128/25 -> [9.0.0.128, 9.0.0.255],
        # 9.0.0.64/26 -> [9.0.0.64, 9.0.0.127],
        # 9.0.0.32/27 -> [9.0.0.32, 9.0.0.63],
        # 9.0.0.1/32 -> [9.0.0.1, 9.0.0.1] For the router.
        "--advertise-routes=9.0.0.128/25,9.0.0.64/26,9.0.0.32/27,9.0.0.1/32"
        "--advertise-exit-node"
        "--accept-routes"
        "--hostname=${shortHostName}"
      ];
    };
  };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
