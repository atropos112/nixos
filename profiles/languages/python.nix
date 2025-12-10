{
  pkgs,
  lib,
  config,
  ...
}: let
  pythonPkg = pkgs.python314;
in {
  environment.systemPackages = with pkgs; [
    # Python
    (pythonPkg.withPackages (ps:
      with ps; [
        pandas
        numpy
      ]))

    # ruff
    uv # pip but faster.

    basedpyright
    ruff
    python313Packages.debugpy
  ];

  environment.sessionVariables = {
    UV_CACHE_DIR = lib.mkIf config.atro.impermanence.enable "/persistent/uv_cache_dir";
  };
}
