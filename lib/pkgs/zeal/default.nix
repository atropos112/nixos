{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zeal
  ];

  xdg.mime.defaultApplications."dash-plugin" = "zeal.desktop";
  home-manager.users.atropos.home.file.".config/Zeal/Zeal.conf".source = ./Zeal.conf;
}
