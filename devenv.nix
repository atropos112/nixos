{pkgs, ...}: {
  languages.nix = {
    enable = true;
    lsp.package = pkgs.nil;
  };

  pre-commit.hooks = {
    deadnix.enable = true;
    alejandra.enable = true;
    shellcheck.enable = true;
    gitleaks = {
      enable = true;
      package = pkgs.gitleaks;
      entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose";
      pass_filenames = false;
    };
    statix = {
      enable = true;
      package = pkgs.statix;
      entry = "${pkgs.statix}/bin/statix check";
      pass_filenames = false;
    };
  };

  enterTest = ''
    nix flake check
  '';
}
