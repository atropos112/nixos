{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.lib.stylix) colors;
  makoOpacity = lib.toHexString (((builtins.ceil (config.stylix.opacity.popups * 100)) * 255) / 100);
in {
  home-manager.users.atropos.services.mako = {
    enable = true;
    package = pkgs.mako;
    # Got to have it manually as opposed to Stylix
    # Because Stylix config comes first and has no timeout...
    settings = lib.mkForce {
      default-timeout = 3000;
      ignore-timeout = 1;
      background-color = "#${colors.base00}${makoOpacity}";
      border-color = "#${colors.base0D}";
      text-color = "#${colors.base0A}";
    };
  };

  # Notification daemon and cli tool
  environment.systemPackages = with pkgs; [
    mako
    libnotify
  ];
}
