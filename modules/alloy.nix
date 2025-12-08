{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.atro.alloy;
  priorityList = import ../utils/priorityList.nix {inherit lib;};
  inherit (lib) mkEnableOption mkIf types;
  inherit (builtins) map concatStringsSep readFile isPath toFile;

  fullConfigFile =
    cfg.configs
    |> priorityList.priorityListToList
    |> map (config:
      if isPath config
      then readFile config
      else config)
    |> concatStringsSep "\n"
    |> toFile "config.alloy";
in {
  options.atro.alloy = {
    enable = mkEnableOption "alloy setup";
    package = lib.mkOption {
      type = types.package;
      default = pkgs.grafana-alloy;
      description = "The alloy package to use.";
    };
    supplementaryGroups = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "systemd-journal" # allow to read the systemd journal for loki log forwarding
        "podman" # allow to read the docker socket
      ];
      description = "Supplementary groups for the alloy service.";
    };
    configs = lib.mkOption {
      type = with lib.types; let
        valueType =
          oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ]
          // {
            description = "ALloy priority list of configs";
          };
      in
        listOf (attrsOf valueType);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (priorityList.validatePriorityList cfg.configs)
    ];

    services.alloy = {
      enable = true;
      extraFlags = [
        "--server.http.listen-addr=127.0.0.1:12346"
        "--feature.community-components.enabled"
        "--disable-reporting"
      ];
      inherit (cfg) package;
      configPath = fullConfigFile;
    };
    # Overriding the default config to include docker for docker socket access
    systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkForce cfg.supplementaryGroups;
  };
}
