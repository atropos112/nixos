{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python312.withPackages (ps: with ps; [pandas numpy]))

    ruff
    poetry
    uv # pip but faster.
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
