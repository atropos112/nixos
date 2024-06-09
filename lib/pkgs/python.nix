{pkgs, ...}: let
  pythonPackages = with pkgs.python312Packages; [
    python-lsp-server
    pylsp-rope
    pylsp-mypy
    debugpy

    pydocstyle
    vulture
    mccabe
    pylint
  ];

  otherPackages = with pkgs; [
    # Python
    python312

    # Linters
    pylint
    ruff

    poetry
    uv # pip but faster.
  ];
in {
  environment.systemPackages = pythonPackages ++ otherPackages;
}
