{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    zfs.forceImportRoot = false;
  };

  environment.systemPackages = with pkgs; [
    zfs-autobackup
  ];

  services = {
    # Filesystem services to make sure data is not corrupted.
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };
}
