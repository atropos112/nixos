{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LSP
    marksman

    # Linter
    markdownlint-cli2
  ];
}
