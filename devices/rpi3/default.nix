{inputs, ...}: {
  imports = [
    ./hardware.nix
    ../../lib/common
    # ./sdimage.nix
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
  ];
  raspberry-pi-nix.board = "bcm2711";
  # raspberry-pi-nix.kernel-version = "v6_6_31";

  topology.self = {
    name = "rpi3";
    # interfaces = {
    #   tailscale0.addresses = ["100.122.175.74" "opi1"];
    #   eth0.addresses = ["9.0.0.5"];
    # };
  };
  networking = {
    # interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "atrorpi3";
  };
}
