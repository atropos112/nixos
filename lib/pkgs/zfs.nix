{
  lib,
  pkgs,
  ...
}: {
  boot = {
    zfs.forceImportRoot = false;
    zfs.package = pkgs.zfs;
  };

  environment.systemPackages = with pkgs; [
    zfs-autobackup
  ];

  services = {
    # Filesystem services to make sure data is not corrupted.
    zfs = {
      trim.enable = true;
      autoSnapshot.enable = true;
      # defaults to 12, which is a bit much given how much data is written
      autoSnapshot.monthly = lib.mkDefault 2;
      autoScrub.enable = true;
    };
  };

  # ZFS already has its own scheduler. Without this my(@Artturin) computer froze for a second when i nix build something.
  # TODO: https://github.com/nix-community/srvos/pull/372 this states its part of nixpkgs already, verify this and if so delete it from here
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';
}
