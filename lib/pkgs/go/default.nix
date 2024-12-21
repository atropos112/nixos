{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls

    go

    ginkgo

    # debugger for golang
    delve
  ];

  home-manager.users.atropos.home.file.".golangci.yml".source = ./golangci.yml;
}
