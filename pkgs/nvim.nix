{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    # Don't want nighltly for 0.12 for now.
    # package = pkgs.neovim; # inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    codespell
  ];
}
