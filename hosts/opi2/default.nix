_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.self = {
    name = "opi2";
    interfaces = {
      tailscale0.addresses = ["opi2"];
      eth0.addresses = ["9.0.0.6"];
    };
  };

  networking = {
    interfaces.eth0.macAddress = "b2:62:c7:54:b7:ee";
    hostName = "atroopi2";
  };
}
