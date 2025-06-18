{
  pkgs,
  config,
  ...
}: {
  sops.secrets."superMaven/configjson" = {
    owner = config.users.users.atropos.name;
  };

  home-manager.users.atropos = {config, ...}: {
    home.file.".supermaven/config.json".source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/superMaven/configjson";
  };

  programs.neovim = {
    enable = true;
    # Don't want nighltly for 0.12 for now.
    # package = pkgs.neovim; # inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    # markdown preview needs it
    yarn

    # lua lang server
    lua-language-server

    # yaml lang server
    yaml-language-server

    # go implem
    impl

    # word dictionary
    wordnet
  ];
}
