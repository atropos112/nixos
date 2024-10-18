{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls

    go_1_23

    ginkgo

    # debugger for golang
    delve

    # Generating code from schema.sql and query.sql to make quiries to well defined tables.
    sqlc
  ];

  home-manager.users.atropos.home.file.".golangci.yml".source = ./config;
}
