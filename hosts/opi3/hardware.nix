_: {
  imports = [
    ../../profiles/common/opi5/hardware.nix
  ];
  atro.disko = {
    hostId = "4671171b";
    drives = [
      "nvme-CT1000P310SSD2_25205009A369"
    ];
  };
}
