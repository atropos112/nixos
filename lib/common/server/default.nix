_: {
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
    cron = {
      enable = true;
      systemCronJobs = [
        # INFO: Prunning docker volumes and images on a regular basis (every day at 04:05)
        # Here flags stand for:
        # --all = prune all images not just dangling ones
        # --volumes = prune volumes that are dangling
        # --force = do not prompt for confirmation
        # So that any node used to do buildx should be cleaned by this operation.
        # Do note this operation can be IO heavy (20-30GB of data being wiped at once).
        "5 4 * * * docker system prune --all --volumes --force"
        # INFO: This is similar to the above but prunes all unused volumes not just dangling ones.
        "15 4 * * * docker volume prune --all --force"
      ];
    };
  };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
