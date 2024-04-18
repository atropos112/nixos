_: {
  imports = [
    ../../lib/common/opi5
  ];
  topology.self = {
    name = "opi1";
    interfaces = {
      tailscale0.addresses = ["100.122.175.74" "opi1"];
      eth0.addresses = ["9.0.0.5"];
    };
  };
  networking = {
    interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "atroopi1";
  };
}
