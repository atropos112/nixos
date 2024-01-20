_: {
  imports = [
    ../../lib/common/opi5
  ];

  networking = {
    interfaces.eth0.macAddress = "aa:01:57:1d:74:15";
    hostName = "atroopi3";
  };
}
