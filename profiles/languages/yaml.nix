{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # yaml lang server
    yaml-language-server
  ];
}
