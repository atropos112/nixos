{pkgs, ...}: {
  packages = [
    pkgs.alejandra
    pkgs.deadnix
  ];

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
  };

  enterTest = ''
    nix flake check
  '';
}
