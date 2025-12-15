_: {
  imports = [
    ../../profiles/common/opi5
    ./hardware.nix
    ../../profiles/impermanence/server.nix
    ../../profiles/networking/dns/london_lan.nix
  ];

  topology.self.interfaces.eth0.addresses = ["9.0.0.7"];

  networking = {
    interfaces.eth0.macAddress = "aa:01:57:1d:74:15";
    hostName = "opi3";
  };
}
