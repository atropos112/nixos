_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.nodes.atroopi2.name = "opi2";

  networking = {
    interfaces.eth0.macAddress = "b2:62:c7:54:b7:ee";
    hostName = "atroopi2";
  };
}
