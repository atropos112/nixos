{pkgs, ...}: let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
in {
  home-manager.users.atropos.services.fusuma = {
    enable = true;
    package = pkgs.fusuma;
    settings = {
      swipe = {
        "3" = {
          left = "${hyprctl} dispatch workspace r+1";
          right = "${hyprctl} dispatch workspace r-1";
        };
        "4" = {
          left = "${hyprctl} dispatch workspace r+1";
          right = "${hyprctl} dispatch workspace r-1";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    fusuma
  ];
}
