{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gofumpt
    golangci-lint
    gopls

    go

    ginkgo

    # debugger for golang
    delve

    # Makefile for go
    mage
  ];

  # INFO: I encountered an issue when trying to debug a test in go. This is the error message:
  # Build Error: go test -c -o /home/atropos/projects/libs/gocore/__debug_bin3999853172 -gcflags all=-N -l ./pubsub
  # # runtime/cgo
  # In file included from /nix/store/wlavaybjbzgllhq11lib6qgr7rm8imgp-glibc-2.39-52-dev/include/bits/libc-header-start.h:33,
  #                  from /nix/store/wlavaybjbzgllhq11lib6qgr7rm8imgp-glibc-2.39-52-dev/include/stdlib.h:26,
  #                  from _cgo_export.c:3:
  # /nix/store/wlavaybjbzgllhq11lib6qgr7rm8imgp-glibc-2.39-52-dev/include/features.h:414:4: error: #warning _FORTIFY_SOURCE requires compiling with optimization (-O) [-Werror=cpp]
  #   414 | #  warning _FORTIFY_SOURCE requires compiling with optimization (-O)
  #       |    ^~~~~~~
  # cc1: all warnings being treated as errors (exit status 1)
  # Setting the CGO_CFLAGS to -O2 fixes the issue. Could also set "-Werror" to not turn warnings into errors but thats less ideal.
  environment.sessionVariables.CGO_CFLAGS = "-O2";

  home-manager.users.atropos.home.file.".golangci.yml".source = ./golangci.yml;
}
