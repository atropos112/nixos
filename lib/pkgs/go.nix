{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls

    # debugger for golang
    delve
  ];
}
