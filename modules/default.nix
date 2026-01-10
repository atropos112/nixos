{
  inputs,
  lib,
  ...
}: let
  autoImports = import ../utils/autoImports.nix {inherit lib;};
in {
  imports =
    # My modules (individual .nix files)
    autoImports.importAllNixFiles {
      exclusions = ["default.nix"];
      path = ./.;
    }
    # My modules (subdirectories with default.nix)
    ++ autoImports.importAllDirectories ./.
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
