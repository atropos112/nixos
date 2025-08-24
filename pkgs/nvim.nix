{
  inputs,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default; # pkgs.neovim for stable
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    codespell
    prettierd
  ];
}
