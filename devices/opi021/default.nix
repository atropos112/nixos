_: {
  imports = [
    ../../lib/common/default.nix
    ../../lib/common/opi02/base.nix
    ../../lib/common/opi02/hardware.nix
  ];

  networking.hostName = "atroopi021";
}
