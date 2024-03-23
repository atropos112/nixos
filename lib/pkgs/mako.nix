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
    extraConfig = lib.mkForce ''
      default-timeout=3000
      ignore-timeout=1

      [urgency=low]
      background-color=#${colors.base00}${makoOpacity}
      border-color=#${colors.base0D}
      text-color=#${colors.base0A}
      default-timeout=3000

      [urgency=high]
      background-color=#${colors.base00}${makoOpacity}
      border-color=#${colors.base0D}
      text-color=#${colors.base08}
      default-timeout=5000
    '';
  };

  # Notification daemon and cli tool
  environment.systemPackages = with pkgs; [
    mako
    libnotify
  ];
}
