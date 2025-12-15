_: {
  imports = [
    ../../profiles/common/opi5
    ./hardware.nix
    ../../profiles/impermanence/server.nix
    ../../profiles/networking/dns/london_lan.nix
  ];

  topology.self.interfaces.eth0.addresses = ["9.0.0.5"];

  networking = {
    interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "opi1";
  };
}
