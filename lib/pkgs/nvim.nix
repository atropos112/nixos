_: {
  programs = {
    # Modern VIM
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # lua package manager
    lua54Packages.luarocks

    # csharp lsp
    csharp-ls

    # python lsp
    python311Packages.python-lsp-server

    # lua lang server
    lua-language-server
  ];
}
