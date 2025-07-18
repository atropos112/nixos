{
  inputs = {
    # NixPkgs stable and unstable branches
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs2311.url = "github:NixOS/nixpkgs/nixos-23.11";
    isd.url = "github:isd-project/isd";
    nix-search-tv.url = "github:3timeslazy/nix-search-tv";
    devenv.url = "github:cachix/devenv";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # Gives me the pipe operator support
    nil_ls = {
      url = "github:oxalica/nil/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Hyprland packages
    # Do not override the nixpkgs input in them as it will be built with different nxipkgs than it was tested with and
    # it will bust the cache on the hyprland cachix server.
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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

    passThroughArgs = system: {
      inherit inputs;
      inherit (inputs) stylix;

      # NOTE: We do not need to set
      # pkgs = import inputs.nixpkgs-unstable {
      #   inherit system config;
      # };
      # as it is already set in nixosSystem function as its from nixpkgs-unstable.lib.
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

    mkHost = hostName: system: (
      (_:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = passThroughArgs system;
          modules = [
            #1. Secrets
            ./secrets

            #2. Modules
            ./modules

            #3. Load full configuration
            ./hosts/${hostName}
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
    };
  in
    {
      # Allows colmena to evaluate the flake purely via `--experimental-flake-eval`.
      colmenaHive = inputs.colmena.lib.makeHive self.colmena;

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
        orth = mkHost "orth" "x86_64-linux";
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
          ./topology/networks.nix
          ./topology/services.nix
          {inherit (self) nixosConfigurations;}
        ];
      };
    });
}
