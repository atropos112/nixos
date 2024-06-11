{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls
  ];
}
