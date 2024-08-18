{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  thisDir = ./.;
  cfg = config.atro.k3s;
  inherit (pkgs) k3s;
  inherit (config.networking) hostName;
in {
  options.atro.k3s = {
    enable = mkEnableOption "boot basics";
    role = mkOption {
      type = types.str;
    };
    serverAddr = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [k3s];
    sops.secrets."k3s/token" = {};

    services.k3s = {
      enable = true;
      inherit (cfg) role serverAddr;
      configPath = mkIf (cfg.role == "server") ./config.yaml;
      tokenFile = config.sops.secrets."k3s/token".path;
      package = k3s;
      extraFlags = "--node-name=${
        if hostName == "atroa21" # Special case... I know, I have regrets.
        then "atro21"
        else hostName
      }";
    };

    environment.etc."rancher/k3s/registries.yaml" = {
      source = "${thisDir}/registries.yaml";
      mode = "0444";
    };
  };
}
