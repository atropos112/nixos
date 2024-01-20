# Clipboard manager
{pkgs, ...}: {
  home-manager.users.atropos.home.file.".config/copyq" = {
    recursive = true;
    source = ./copyq;
  };

  environment.systemPackages = [pkgs.copyq];
}
