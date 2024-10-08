{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls

    go_1_23

    ginkgo

    # debugger for golang
    delve
  ];

  home-manager.users.atropos.home.file.".golangci.yml".source = ./golangci.yml;
}
