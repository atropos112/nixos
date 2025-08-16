{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: {
    packages.x86_64-linux.default = self.nixosConfigurations.exampleIso.config.system.build.isoImage;
    nixosConfigurations = {
      exampleIso = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({
            pkgs,
            modulesPath,
            ...
          }: let
            inherit (pkgs) lib;
          in {
            imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];
            environment.systemPackages = [pkgs.neovim];
            environment.etc."nixos-generate-config.conf".text = ''
              [Defaults]
              Kernel=latest
            '';
            boot = {
              kernelPackages = pkgs.linuxPackages_6_15;
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
          })
        ];
      };
    };
  };
}
