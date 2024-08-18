{
  inputs = {
    # NixPkgs stable and unstable branches
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs2311.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Hyprland packages
    # Do not override the nixpkgs input in them as it will be built with different nxipkgs than it was tested with and
    # it will bust the cache on the hyprland cachix server.
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xdg-desktop-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

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

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
    nxpkg = {
      "stable" = inputs.nixpkgs-stable;
      "unstable" = inputs.nixpkgs-unstable;
      "old2311" = inputs.nixpkgs2311;
    };
    hm = {
      "stable" = inputs.home-manager-stable;
      "unstable" = inputs.home-manager;
    };

    mkHost = hostName: system: branch: (
      (_:
        nxpkg."${branch}".lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs self;
            inherit (inputs) stylix;
            pkgs = import nxpkg."${branch}" {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                # fix the following error :
                # modprobe: FATAL: Module ahci not found in directory
                # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
                (_: super: {
                  makeModulesClosure = x:
                    super.makeModulesClosure (x // {allowMissing = true;});
                })
              ];
            };
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
            pkgs2311 = import inputs.nixpkgs2311 {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            #1. Home-manager
            hm."${branch}".nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
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
      sdImage-rpi3 = self.nixosConfigurations.rpi3.config.system.build.sdImage;
      sdImage-opi021 = self.nixosConfigurations.opi021.config.system.build.sdImage;
    };
  in
    {
      nixosConfigurations = {
        surface = mkHost "surface" "x86_64-linux" "unstable";
        giant = mkHost "giant" "x86_64-linux" "unstable";
        smol = mkHost "smol" "x86_64-linux" "unstable";
        a21 = mkHost "a21" "x86_64-linux" "unstable";
        rzr = mkHost "rzr" "x86_64-linux" "unstable";
        opi1 = mkHost "opi1" "aarch64-linux" "unstable";
        opi2 = mkHost "opi2" "aarch64-linux" "unstable";
        opi3 = mkHost "opi3" "aarch64-linux" "unstable";
        opi4 = mkHost "opi4" "aarch64-linux" "unstable";
        rpi3 = mkHost "rpi3" "aarch64-linux" "stable";
        opi021 = mkHost "opi021" "aarch64-linux" "unstable";
      };

      packages = {
        x86_64-linux = sdImages;
        aarch64-linux = sdImages;
      };

      colmena =
        {
          meta = {
            description = "my personal machines";
            nixpkgs = import inputs.nixpkgs-unstable {system = "x86_64-linux";}; # Gets overriden by the host-specific nixpkgs.
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
          # Change arch to aarch64 if the system is aarch64-linux
          nixpkgs.system =
            if (value.config.nixpkgs.system == "aarch64-linux")
            then "aarch64-linux"
            else "x86_64-linux";

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
