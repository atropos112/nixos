{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # THe basics
    zig

    # LSP
    zls
  ];
}
