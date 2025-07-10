{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # The basics
    zig

    # LSP
    zls
  ];
}
