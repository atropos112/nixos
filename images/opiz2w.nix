{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    ../profiles/identities/users.nix
  ];
  environment.systemPackages = [pkgs.neovim];
  boot.kernelPackages = pkgs.linuxPackages_6_15;
}
