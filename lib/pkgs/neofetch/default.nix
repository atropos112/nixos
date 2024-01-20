# Nice display what my system is TUI message.
{pkgs, ...}: {
  home-manager.users.atropos.home.file.".config/neofetch/config.conf".source = ./config.conf;
  environment.systemPackages = [pkgs.neofetch];
}
