_: {
  imports = [
    ../../profiles/common/opi5/hardware.nix
  ];
  atro.diskoZfsRoot = {
    hostId = "4671711a";
    drives = [
      "nvme-CT1000P310SSD2_25205025897F"
    ];
  };
}
