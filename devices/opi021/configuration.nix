_: {
  imports = [
    ../common/base.nix
    ../common/opi02/base.nix
    ../common/opi02/hardware.nix
  ];

  networking.hostName = "atroopi021";
}
