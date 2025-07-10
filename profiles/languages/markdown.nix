{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LSP
    marksman

    # Linter
    markdownlint-cli2

    # word dictionary
    wordnet

    # markdown preview needs it
    yarn
  ];
}
