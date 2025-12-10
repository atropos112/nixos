{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    clang
    clang-tools
  ];
}
