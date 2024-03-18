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

  services = {
    # vpn mesh to connect to other devices
    tailscale = {
      useRoutingFeatures = "both";
      extraUpFlags = [
        "--advertise-routes=9.0.0.0/24"
        "--advertise-exit-node"
      ];
    };
  };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
