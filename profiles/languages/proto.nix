{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    buf
  ];
}
