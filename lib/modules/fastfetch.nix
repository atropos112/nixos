{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.fastfetch;
in {
  options.atro.fastfetch = {
    enable = mkEnableOption "fastfetch setup";
    baseModules = lib.mkOption {
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
            description = "Fastfetch base modules";
          };
      in
        valueType;
      default = {};
    };
    extraModules = lib.mkOption {
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
            description = "Fastfetch extra modules";
          };
      in
        valueType;
      default = {};
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      fastfetch
    ];

    home-manager.users.atropos.programs = {
      fastfetch = {
        enable = true;
        package = pkgs.fastfetch;
        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          "modules" = lib.mkMerge [
            cfg.baseModules
            cfg.extraModules
            ["break"]
          ];
        };
      };
    };
  };
}
