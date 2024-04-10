{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    python311Full
    python312Full
    python313Full

    # python lsp
    pylint

    # Python LSP serves
    python311Packages.python-lsp-server

    # Python package manager (Poetry)
    poetry

    # Pip but faster
    uv
  ];
}
