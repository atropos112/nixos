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

  # Build the full config by concatenating all configs from the priority list
  # Then validate the syntax using alloy fmt to catch errors at build time
  fullConfigFile = let
    uncheckedConfig =
      cfg.configs
      |> priorityList.priorityListToList
      |> map (config:
        if isPath config
        then readFile config
        else config)
      |> concatStringsSep "\n"
      |> toFile "config.alloy";

    # Validate the config syntax at build time
    # If syntax is invalid, the build will fail with a helpful error message
    validatedConfig =
      pkgs.runCommand "validated-config.alloy" {
        nativeBuildInputs = [cfg.package];
      } ''
        # Copy the unvalidated config to output location
        cp ${uncheckedConfig} $out

        # Validate syntax using alloy fmt
        # This will exit with non-zero if there are syntax errors
        if ! ${cfg.package}/bin/alloy fmt $out > /dev/null 2>&1; then
          echo "================================================================"
          echo "ERROR: Alloy configuration syntax validation failed!"
          echo "================================================================"
          echo ""
          echo "The Alloy configuration has syntax errors and cannot be used."
          echo ""
          echo "To debug the issue, examine the configuration below or run:"
          echo "  alloy fmt ${uncheckedConfig}"
          echo ""
          echo "----------------------------------------------------------------"
          echo "Configuration content:"
          echo "----------------------------------------------------------------"
          cat $out
          echo "----------------------------------------------------------------"
          exit 1
        fi

        echo "Alloy configuration syntax validated successfully"
      '';
  in
    validatedConfig;
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

    # Allow alloy to query systemd via dbus for the systemd collector
    services.dbus.packages = [
      (pkgs.writeTextDir "share/dbus-1/system.d/alloy-systemd.conf" ''
        <!DOCTYPE busconfig PUBLIC
          "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
          "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy user="alloy">
            <allow send_destination="org.freedesktop.systemd1"/>
            <allow receive_sender="org.freedesktop.systemd1"/>
          </policy>
        </busconfig>
      '')
    ];
  };
}
