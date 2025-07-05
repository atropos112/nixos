{lib, ...}: let
  autoImports = import ../../utils/autoImports.nix {inherit lib;};
in {
  imports = autoImports.importAllNixFiles {
    exclusions = ["all.nix"]; # Exclude this file to avoid infinite recursion
    path = ./.;
  };

  atro.externalMounts.enable = true;
}
