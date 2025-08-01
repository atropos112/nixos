{pkgs, ...}: {
  imports = [
    ../../profiles/zfs.nix
  ];
  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];

  boot.kernelPackages = pkgs.linuxPackages_6_15;
}
