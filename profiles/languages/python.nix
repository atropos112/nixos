{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python314.withPackages (ps:
      with ps; [
        pandas
        numpy
      ]))

    ruff
    uv # pip but faster.

    basedpyright

    python314Packages.python-lsp-server
  ];

  environment.sessionVariables.UV_CACHE_DIR = lib.mkIf config.atro.impermanence.enable "/persistent/uv_cache_dir";
}
