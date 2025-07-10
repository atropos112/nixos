_: {
  imports = [
    ../../profiles/common/basic.nix
    ../../profiles/common/server.nix
    ./hardware.nix
  ];

  topology.self = {
    name = "orth";
    interfaces = {
      tailscale0.addresses = ["orth"];
      # eth0.addresses = ["?.?.?.?"];
    };
    hardware.info = "Parents backup";
  };

  networking = {
    hostName = "orth";
    # interfaces.eth0.macAddress = "2c:f0:5d:26:8d:da";
  };
}
