{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.atro.hyprland;
  priorityList = import ../utils/priorityList.nix {inherit lib;};
in {
  options.atro.hyprland = {
    enable = mkEnableOption "hyprland setup";
    settings = lib.mkOption {
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
            description = "Hyprland configuration values priority list";
          };
      in
        listOf (attrsOf valueType);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (priorityList.validatePriorityList cfg.settings)
    ];

    # Duplicating config in both home-manager and nixos programs is not ideal, but it works.
    # Need to use both because home-manager doesn't let me input portalPackage while
    # nixos doesn't let me input settings.

    programs = {
      # Desktop environment (DE), this is provides the GUI post login.
      hyprland = {
        enable = true;
        xwayland.enable = true; # jetbrains needs it, spotify and so on
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };

    home-manager.users.atropos.wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = cfg.settings |> priorityList.priorityListToList |> lib.mkMerge;
    };
  };
}
