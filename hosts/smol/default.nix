_: {
  imports = [
    ./hardware.nix
    ../../profiles/common/basic.nix
    ../../profiles/common/server.nix
    ../../profiles/kubernetes/server.nix
    ../../profiles/kubernetes/user.nix
    ../../profiles/impermanence/server.nix
    ../../profiles/networking/dns_london.nix
  ];

  topology.self = {
    name = "smol";
    interfaces = {
      tailscale0.addresses = ["smol"];
      eth0.addresses = ["9.0.0.4"];
    };
    hardware.info = "i5-10210U, 16GB (DDR4), K8s Master";
  };

  networking = {
    hostName = "smol";
    interfaces.eth0.macAddress = "2c:f0:5d:26:8d:da";
  };
}
