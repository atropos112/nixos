{
  inputs = {
    # NixPkgs stable and unstable branches
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nix-search-tv.url = "github:3timeslazy/nix-search-tv";

    # nix stuff
    statix.url = "github:oppiliappan/statix/master";
    # Gives me the pipe operator support
    nil_ls = {
      url = "github:oxalica/nil/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

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

    devenv.url = "github:cachix/devenv";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
      pkgs-master = import inputs.nixpkgs-master {
        inherit system config;
      };
    };

    mkImage = name: system: (
      (_:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = passThroughArgs system;
          modules = [
            # 1. Secrets
            # Unlike in mkHost, we only load the module as install image should not need secrets.
            # If a secret is attempted to be used, it will fail at build time, this is by design.
            inputs.sops-nix.nixosModules.sops

            # 2. Modules
            ./modules

            # 3. Load image configuration
            ./images/${name}.nix
          ];
        }) {}
    );

    mkHost = hostName: system: (
      (_:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = passThroughArgs system;
          modules = [
            # 1. Secrets
            ./secrets

            # 2. Modules
            ./modules

            # 3. Load full configuration
            ./hosts/${hostName}
          ];
        }) {}
    );

    # Little hack to get colmena to work with nixos-rebuild switch interoperably.
    conf = self.nixosConfigurations;
  in
    {
      # Allows colmena to evaluate the flake purely via `--experimental-flake-eval`.
      colmenaHive = inputs.colmena.lib.makeHive self.colmena;

      nixosConfigurations = {
        frame = mkHost "frame" "x86_64-linux";
        giant = mkHost "giant" "x86_64-linux";
        smol = mkHost "smol" "x86_64-linux";
        a21 = mkHost "a21" "x86_64-linux";
        rzr = mkHost "rzr" "x86_64-linux";
        opi1 = mkHost "opi1" "aarch64-linux";
        opi2 = mkHost "opi2" "aarch64-linux";
        opi3 = mkHost "opi3" "aarch64-linux";
        opi4 = mkHost "opi4" "aarch64-linux";
        orth = mkHost "orth" "x86_64-linux";
        # To build the imageZfsArm run:
        # nix build .#nixosConfigurations.imageZfsArm.config.system.build.isoImage
        imageZfsArm = mkImage "zfs" "aarch64-linux";
        imageZfsAmd = mkImage "zfs" "x86_64-linux";

        # To build the opiz2wImage run:
        # nix build .#nixosConfigurations.imageOpiz2w.config.system.build.sdImage
        imageOpiz2w = mkImage "opiz2w" "aarch64-linux";
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
    # eachDefaultSystem maps packages.hello to packages.<system>.hello
    // inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        overlays = [inputs.nix-topology.overlays.default];
      };
    in {
      topology = import inputs.nix-topology {
        inherit pkgs;

        modules = [
          ./topology/networks.nix
          ./topology/services.nix
          {inherit (self) nixosConfigurations;}
        ];
      };
    });
}
