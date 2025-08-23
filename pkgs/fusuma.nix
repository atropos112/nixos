{
  inputs,
  pkgs,
  ...
}: {
  home-manager.users.atropos.services.fusuma = {
    enable = true;
    package = pkgs.fusuma;
    extraPackages = [
      inputs.hyprland.packages.${pkgs.system}.hyprland # For hyprctl command
      pkgs.coreutils # Necessary for fusuma to work at all
    ];
    settings = {
      swipe = {
        "3" = {
          left = {
            command = "hyprctl dispatch workspace r+1";
          };
          right = {
            command = "hyprctl dispatch workspace r-1";
          };
        };
        "4" = {
          left = {
            command = "hyprctl dispatch workspace r+1";
          };
          right = {
            command = "hyprctl dispatch workspace r-1";
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    fusuma
  ];
}
