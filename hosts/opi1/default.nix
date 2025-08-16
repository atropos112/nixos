_: {
  imports = [
    ../../profiles/common/opi5
    ./hardware.nix
    ../../profiles/impermanence/server.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  topology.self = {
    name = "opi1";
    interfaces = {
      tailscale0.addresses = ["opi1"];
      eth0.addresses = ["9.0.0.5"];
    };
  };

  networking = {
    # interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "atroopi1";
  };
}
