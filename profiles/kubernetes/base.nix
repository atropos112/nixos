{
  pkgs-master,
  config,
  lib,
  ...
}: let
  inherit (config.networking) hostName;
in {
  imports = [
    ./longhorn.nix
  ];

  sops.secrets."k3s/token" = {};

  # Overriding the default config to include docker for docker socket access
  systemd.services.alloy.environment = lib.mkForce {
    K8S_NODE_NAME = hostName;
  };

  environment.sessionVariables = {
    K8S_NODE_NAME = hostName;
  };

  services.k3s = {
    enable = true;
    serverAddr = "https://11.0.0.11:6443";
    tokenFile = config.sops.secrets."k3s/token".path;
    package = pkgs-master.k3s;
    extraFlags = [
      "--node-name ${hostName}"
    ];
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
