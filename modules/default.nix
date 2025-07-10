{
  inputs,
  lib,
  ...
}: let
  autoImports = import ../utils/autoImports.nix {inherit lib;};
in {
  # Auto import all directories
  imports =
    # My modules
    autoImports.importAllNixFiles {
      exclusions = ["default.nix"]; # Exclude this file to avoid infinite recursion
      path = ./.;
    }
    # External modules
    ++ [
      inputs.nix-topology.nixosModules.default

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useUserPackages = true;
        };
      }
    ];
}
