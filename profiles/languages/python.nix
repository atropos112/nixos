{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python313.withPackages (ps:
      with ps; [
        pandas
        numpy
      ]))

    ruff
    poetry
    uv # pip but faster.

    basedpyright

    python313Packages.python-lsp-server
    python313Packages.debugpy
  ];
  home-manager.users.atropos.programs.poetry = {
    enable = true;
    package = pkgs.poetry;
    settings = {
      virtualenvs = {
        in-project = true;
        prefer-active-python = true;
        use-poetry-python = false;
      };
    };
  };
}
