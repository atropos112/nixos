{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel.nix")
    ../profiles/identities/users.nix
  ];
  environment.systemPackages = [pkgs.neovim];
  boot.supportedFilesystems.zfs = lib.mkForce false;
  environment.etc."nixos-generate-config.conf".text = ''
    [Defaults]
    Kernel=latest
  '';
}
