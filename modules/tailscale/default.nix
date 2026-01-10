{lib, ...}: let
  autoImports = import ../../utils/autoImports.nix {inherit lib;};
in {
  imports = autoImports.importAllNixFiles {
    exclusions = ["default.nix"];
    path = ./.;
  };
}
