_: {
  imports = [
    ../../profiles/common/opi5
    ./hardware.nix
    ../../profiles/impermanence/server.nix
    ../../profiles/networking/dns_london.nix
  ];

  topology.self.interfaces.eth0.addresses = ["9.0.0.8"];

  networking = {
    interfaces.eth0.macAddress = "6a:5c:cf:00:bc:a4";
    hostName = "opi4";
  };
}
