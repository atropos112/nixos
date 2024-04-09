_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.nodes.atroopi1.name = "opi1";

  networking = {
    interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "atroopi1";
  };
}
