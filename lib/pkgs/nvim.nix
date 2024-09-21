{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    neovim = {
      enable = true;
    };
  };

  # My nvim config is placed in store as an input and then placed in ~/.config/nix-store-nvim
  home-manager.users.atropos.home.file.".config/nix-store-nvim".source = inputs.atro-nvim;

  # NVIM_APPNAME is then used to load the correct config
  environment.sessionVariables.ATRO_NIX_STORE_NVIM = "${inputs.atro-nvim}/init.lua";

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
