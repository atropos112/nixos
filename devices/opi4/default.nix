_: {
  imports = [
    ../../lib/common/opi5
  ];

  topology.self = {
    name = "opi4";
    interfaces = {
      tailscale0.addresses = ["100.117.231.60" "opi4"];
      eth0.addresses = ["9.0.0.8"];
    };
  };

  networking = {
    interfaces.eth0.macAddress = "6a:5c:cf:00:bc:a4";
    hostName = "atroopi4";
  };
}
