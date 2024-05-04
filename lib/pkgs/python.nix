{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python311Full.withPackages (ps:
      with ps; [
        python-lsp-server
        pylsp-rope
        python-lsp-ruff
        pydocstyle
        vulture
        mccabe
        pylint
        debugpy
      ]))

    # Linters
    pylint
    ruff

    # Python package managers
    poetry
    uv # pip but faster.
  ];
}
