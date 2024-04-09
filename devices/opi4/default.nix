_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.nodes.atroopi4.name = "opi4";

  networking = {
    interfaces.eth0.macAddress = "6a:5c:cf:00:bc:a4";
    hostName = "atroopi4";
  };
}
