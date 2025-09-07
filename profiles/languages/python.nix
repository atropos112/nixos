{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python313.withPackages (ps:
      with ps; [
        pandas
        numpy
      ]))

    ruff
    uv # pip but faster.

    basedpyright

    python313Packages.python-lsp-server
    python313Packages.debugpy
  ];

  environment.sessionVariables.UV_CACHE_DIR = lib.mkIf config.atro.impermanence.enable "/persistent/uv_cache_dir";
}
