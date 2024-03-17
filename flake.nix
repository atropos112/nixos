{
  inputs = {
    # NixPkgs stable and unstable branches
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    # Hyprland packages
    # Do not override the nixpkgs input in them as it will be built with different nxipkgs than it was tested with and
    # it will bust the cache on the hyprland cachix server.
    hyprland.url = "github:hyprwm/Hyprland";
    xdg-desktop-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    devenv = {
      url = "github:cachix/devenv";
    };
  };
  outputs = {self, ...} @ inputs: let
    mkHost = hostName: system: (
      (_:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs self;
            inherit (inputs) nix-colors;
            pkgs = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            #1. Home-manager
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }

            #2. Loading device specific configuration
            ./devices/${hostName}
          ];
        }) {}
    );

    # Little hack to get colmena to work with nixos-rebuild switch interoperably.
    conf = self.nixosConfigurations;
  in {
    inherit inputs;
    nixosConfigurations = {
      surface = mkHost "surface" "x86_64-linux";
      giant = mkHost "giant" "x86_64-linux";
      smol = mkHost "smol" "x86_64-linux";
      a21 = mkHost "a21" "x86_64-linux";
      rzr = mkHost "rzr" "x86_64-linux";
      opi1 = mkHost "opi1" "aarch64-linux";
      opi2 = mkHost "opi2" "aarch64-linux";
      opi3 = mkHost "opi3" "aarch64-linux";
      opi4 = mkHost "opi4" "aarch64-linux";
      opi021 = mkHost "opi021" "aarch64-linux"; # BROKEN at the moment, memory issues
    };

    packages.x86_64-linux = {
      sdImage-opi1 = self.nixosConfigurations.opi1.config.system.build.sdImage;
      sdImage-opi2 = self.nixosConfigurations.opi2.config.system.build.sdImage;
      sdImage-opi3 = self.nixosConfigurations.opi3.config.system.build.sdImage;
      sdImage-opi4 = self.nixosConfigurations.opi4.config.system.build.sdImage;
      sdImage-opi021 = self.nixosConfigurations.opi021.config.system.build.sdImage;
    };

    colmena =
      {
        meta = {
          description = "my personal machines";
          nixpkgs = import inputs.nixpkgs-unstable {system = "x86_64-linux";}; # Gets overriden by the host-specific nixpkgs.
          nodeSpecialArgs = builtins.mapAttrs (_name: value: value._module.specialArgs) conf;
        };
      }
      // builtins.mapAttrs (_name: value: {
        deployment = {
          allowLocalDeployment = true;
          targetUser = "root";
          buildOnTarget = true;
          targetHost = "9.0.0.8"; # name;
        };
        # Change arch to aarch64 if the system is aarch64-linux
        nixpkgs.system =
          if (value.config.nixpkgs.system == "aarch64-linux")
          then "aarch64-linux"
          else "x86_64-linux";

        imports = value._module.args.modules;
      })
      conf;
  };
}
