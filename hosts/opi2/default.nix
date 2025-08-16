_: {
  imports = [
    ../../profiles/common/opi5
    ./hardware.nix
    ../../profiles/impermanence/server.nix
  ];

  topology.self.interfaces.eth0.addresses = ["9.0.0.6"];

  networking = {
    interfaces.eth0.macAddress = "b2:62:c7:54:b7:ee";
    hostName = "opi2";
  };
}
