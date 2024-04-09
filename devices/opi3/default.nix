_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.nodes.atroopi3.name = "opi3";

  networking = {
    interfaces.eth0.macAddress = "aa:01:57:1d:74:15";
    hostName = "atroopi3";
  };
}
