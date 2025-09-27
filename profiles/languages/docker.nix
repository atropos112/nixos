{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LSP
    docker-ls

    # Linter
    hadolint

    dockerfile-language-server
  ];
}
