{
  inputs,
  lib,
  ...
}: let
  hosts = {
    giant = "x86_64-linux";
    surface = "x86_64-linux";

    rzr = "x86_64-linux";
    smol = "x86_64-linux";
    a21 = "x86_64-linux";

    opi1 = "aarch64-linux";
    opi2 = "aarch64-linux";
    opi3 = "aarch64-linux";
    opi4 = "aarch64-linux";
  };

  config = {
    allowUnfree = true;
    allowBroken = false;
  };
  inherit (inputs.nixpkgs-unstable.lib) nixosSystem;
  # TODO: Add modules
  # inherit (import "${self}/modules/nixos") default;

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
  mkHost = {
    hostName,
    system,
  }:
    nixosSystem {
      inherit system;
      specialArgs = passThroughArgs system;
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
        ./${hostName}

        #3. Topology
        inputs.nix-topology.nixosModules.default
      ];
    };
  nixosConfigurations = lib.mapAttrs (hostName: system: mkHost {inherit hostName system;}) hosts;
in {
  flake = {
    inherit nixosConfigurations;
    deploy.nodes =
      builtins.mapAttrs (hostname: system: {
        inherit hostname;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos nixosConfigurations.${hostname};
        };
      })
      hosts;
  };
}
