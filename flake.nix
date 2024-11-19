{
  inputs = {
    # NixPkgs stable and unstable branches
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs2311.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    atro-nvim = {
      url = "github:atropos112/nvim";
      flake = false;
    };

    # Hyprland packages
    # Do not override the nixpkgs input in them as it will be built with different nxipkgs than it was tested with and
    # it will bust the cache on the hyprland cachix server.
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    stylix.url = "github:danth/stylix";
    impermanence.url = "github:nix-community/impermanence";

    atuin.url = "github:atuinsh/atuin";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

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
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    eza = {
      url = "github:eza-community/eza";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = {self, ...} @ inputs: let
    config = {
      allowUnfree = true;
      allowBroken = false;
    };
    mkHost = hostName: system: (
      (_:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs self;
            inherit (inputs) stylix;
            pkgs = import inputs.nixpkgs-unstable {
              inherit system config;
            };
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system config;
            };
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system config;
            };
            pkgs2311 = import inputs.nixpkgs2311 {
              inherit system config;
            };
          };
          modules = [
            #1. Home-manager
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }

            #2. Loading device specific configuration
            ./devices/${hostName}

            #3. Topology
            inputs.nix-topology.nixosModules.default
          ];
        }) {}
    );

    # Little hack to get colmena to work with nixos-rebuild switch interoperably.
    conf = self.nixosConfigurations;
    sdImages = {
      sdImage-opi1 = self.nixosConfigurations.opi1.config.system.build.sdImage;
      sdImage-opi2 = self.nixosConfigurations.opi2.config.system.build.sdImage;
      sdImage-opi3 = self.nixosConfigurations.opi3.config.system.build.sdImage;
      sdImage-opi4 = self.nixosConfigurations.opi4.config.system.build.sdImage;
      sdImage-opi021 = self.nixosConfigurations.opi021.config.system.build.sdImage;
    };
  in
    {
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
      };

      packages = {
        x86_64-linux = sdImages;
        aarch64-linux = sdImages;
      };

      colmena =
        {
          meta = {
            description = "my personal machines";
            nixpkgs = import inputs.nixpkgs-unstable {system = "x86_64-linux";}; # Gets overwritten by the host-specific nixpkgs.
            nodeSpecialArgs = builtins.mapAttrs (_name: value: value._module.specialArgs) conf;
          };
        }
        // builtins.mapAttrs (name: value: {
          deployment = {
            allowLocalDeployment = true;
            targetUser = "root";
            buildOnTarget = true;
            targetHost = name;
          };
          nixpkgs.system = value.config.nixpkgs.system;
          imports = value._module.args.modules;
        })
        conf;
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: {
      topology = import inputs.nix-topology {
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          overlays = [inputs.nix-topology.overlays.default];
        };

        modules = [
          ./lib/topology/networks.nix
          ./lib/topology/services.nix
          {inherit (self) nixosConfigurations;}
        ];
      };
    });
}
