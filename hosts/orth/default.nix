_: {
  imports = [
    ../../profiles/common/basic.nix
    ../../profiles/common/server.nix
    ../../profiles/services/garage.nix
    ../../profiles/services/syncthing.nix
    ../../pkgs/adguardhome.nix
    ./hardware.nix
  ];

  atro = {
    garage = {
      # Typically data is the slow but high capacity storage,
      # and metadataDir is the fast but lower capacity storage.
      # But all this device has is 4 NVME drives so its one and the same.
      data = {
        dir = "/persistent/garage/data";
        capacity = "4T";
      };
      metadataDir = "/persistent/garage/metadata";
    };
  };

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
    interfaces.eth0.macAddress = "a8:b8:e0:08:04:07";
  };
}
