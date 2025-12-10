{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    clang
  ];
}
