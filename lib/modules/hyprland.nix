{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.hyprland;
in {
  options.atro.hyprland = {
    enable = mkEnableOption "hyprland setup";
    baseSettings = lib.mkOption {
      type = with lib.types; let
        valueType =
          nullOr (oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ])
          // {
            description = "Hyprland configuration value";
          };
      in
        valueType;
      default = {};
    };
    deviceSpecificSettings = lib.mkOption {
      type = with lib.types; let
        valueType =
          nullOr (oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ])
          // {
            description = "Hyprland configuration value";
          };
      in
        valueType;
      default = {};
    };
  };

  config = {
    # Duplicating config in both home-manager and nixos programs is not ideal, but it works.
    # Need to use both because home-manager doesn't let me input portalPackage while
    # nixos doesn't let me input settings.

    programs = {
      # Desktop environment (DE), this is provides the GUI post login.
      hyprland = {
        enable = true;
        xwayland.enable = true; # jetbrains needs it, spotify and so on
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        portalPackage = inputs.xdg-desktop-portal-hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      };
    };

    home-manager.users.atropos.wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      settings = lib.mkMerge [
        cfg.baseSettings
        cfg.deviceSpecificSettings
      ];
    };
  };
}
