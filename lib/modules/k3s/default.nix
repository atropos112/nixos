{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.atro.k3s;
  inherit (pkgs) k3s;
  inherit (config.networking) hostName;

  # Special case... I know, I have regrets.
  nodeName =
    if hostName == "atroa21"
    then "atro21"
    else hostName;
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

    home-manager.users.root.home.file = {
      "k3s/kubelet-config.yaml".source = ./kubelet-config.yaml;
      "k3s/tracing-config.yaml".source = ./tracing-config.yaml;
    };

    # Overriding the default config to include docker for docker socket access
    systemd.services.alloy.environment = lib.mkForce {
      K8S_NODE_NAME = nodeName;
    };

    environment.sessionVariables = {
      K8S_NODE_NAME = nodeName;
    };

    services.k3s = {
      enable = true;
      inherit (cfg) role serverAddr;
      configPath = mkIf (cfg.role == "server") ./config.yaml;
      tokenFile = config.sops.secrets."k3s/token".path;
      package = k3s;
      extraFlags = "--node-name=${nodeName}";
    };
  };
}
