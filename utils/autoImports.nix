# Typical usage:
# autoImports = import ../utils/autoImports.nix { inherit lib; };
# ...
# imports = autoImports.importAllNixFiles{exclusions = ["my_file_name.nix"]; path = ./.;};
#
# here my_file_name.nix is the file name that is calling this file, it has to be excluded from the auto import
# to avoid infinite recursion.
{lib}: {
  importAllNixFiles = {
    exclusions,
    path,
  }:
    builtins.readDir path
    # Filter for .nix files
    |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && builtins.elem name exclusions == false)
    # Convert to file paths
    |> lib.mapAttrsToList (name: _: path + "/${name}");

  importAllDirectories = path:
    builtins.readDir path
    # Filter for directories
    |> lib.filterAttrs (_: type: type == "directory")
    # Convert to file paths
    |> lib.mapAttrsToList (name: _: path + "/${name}");
}
