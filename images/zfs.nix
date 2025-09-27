{
  pkgs,
  modulesPath,
  ...
}: let
  inherit (pkgs) lib;
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../profiles/identities/users.nix
  ];
  environment.systemPackages = [pkgs.neovim];
  environment.etc."nixos-generate-config.conf".text = ''
    [Defaults]
    Kernel=latest
  '';
  boot = {
    kernelPackages = pkgs.linuxPackages_6_16;
    supportedFilesystems = {
      ext4 = lib.mkForce true;
      zfs = lib.mkForce true;
    };
    initrd = {
      supportedFilesystems = {
        ext4 = lib.mkForce true;
        zfs = lib.mkForce true;
      };
    };

    loader.grub.zfsSupport = true;
    zfs.forceImportRoot = false;
    zfs.package = pkgs.zfs;
  };
}
