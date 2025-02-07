_: {
  imports = [
    ./longhorn.nix
    ../../modules/k3s
    ../default.nix
  ];

  atro.k3s = {
    enable = true;
    serverAddr = "https://11.0.0.11:6443";
  };

  atro.fastfetch.extraModules = [
    {
      "type" = "command";
      "text" = "systemctl is-active k3s";
      "key" = "K3s";
    }
  ];
}
