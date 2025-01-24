{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LSP
    docker-compose-language-service
    docker-ls

    # Linter
    hadolint
  ];
}
