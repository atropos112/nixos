_: {
  imports = [
    ../../profiles/common/opi5
  ];

  topology.self = {
    name = "opi3";
    interfaces = {
      tailscale0.addresses = ["opi3"];
      eth0.addresses = ["9.0.0.7"];
    };
  };

  networking = {
    interfaces.eth0.macAddress = "aa:01:57:1d:74:15";
    hostName = "atroopi3";
  };
}
