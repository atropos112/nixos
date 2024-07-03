{pkgs, ...}: {
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # lua package manager
    lua54Packages.luarocks

    # markdown preview needs it
    yarn

    # lua lang server
    lua-language-server

    # yaml lang server
    yaml-language-server

    # go implem
    impl
  ];
}
