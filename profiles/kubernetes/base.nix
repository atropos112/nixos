{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.networking) hostName;

  # Special case... I know, I have regrets.
  nodeName =
    if hostName == "atroa21"
    then "atro21"
    else hostName;
in {
  imports = [
    ./longhorn.nix
  ];

  sops.secrets."k3s/token" = {};

  # Overriding the default config to include docker for docker socket access
  systemd.services.alloy.environment = lib.mkForce {
    K8S_NODE_NAME = nodeName;
  };

  environment.sessionVariables = {
    K8S_NODE_NAME = nodeName;
  };

  services.k3s = {
    enable = true;
    serverAddr = "https://11.0.0.11:6443";
    tokenFile = config.sops.secrets."k3s/token".path;
    package = pkgs.k3s;
    extraFlags = "--node-name=${nodeName}";
  };

  # Needed for grafana alloy but also convininient.
  # Grafana alloy infact needs this to be called "kubeconfig" so it exists
  # in /run/secrets/kubeconfig as well
  sops.secrets."kubeconfig" = {
    owner = "atropos";
    path = "/home/atropos/.kube/config";
    mode = "0444"; # Read only
  };
  atro.fastfetch.modules = [
    {
      priority = 1005;
      value = {
        "type" = "command";
        "text" = "systemctl is-active k3s";
        "key" = "K3s";
      };
    }
  ];
}
