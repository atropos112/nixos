{lib, ...}: let
  autoImports = import ../utils/autoImports.nix {inherit lib;};
in {
  # Auto import all directories
  imports = autoImports.importAllDirectories ./.;
}
