{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.fastfetch;
  priorityList = import ../../utils/priorityList.nix {inherit lib;};
in {
  options.atro.fastfetch = {
    enable = mkEnableOption "fastfetch setup";
    modules = lib.mkOption {
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
            description = "Fastfetch priority list of modules";
          };
      in
        listOf (attrsOf valueType);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (priorityList.validatePriorityList cfg.modules)
    ];

    environment.systemPackages = with pkgs; [
      fastfetch
    ];

    home-manager.users.atropos.programs = {
      fastfetch = {
        enable = true;
        package = pkgs.fastfetch;
        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          "modules" = (priorityList.priorityListToList cfg.modules) ++ ["break"];
        };
      };
    };
  };
}
