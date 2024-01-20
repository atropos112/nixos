{pkgs, ...}: {
  home-manager.users.atropos.home.file.".config/tofi/config".source = ./config;
  environment.systemPackages = [pkgs.tofi];
}
