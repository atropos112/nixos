_: {
  imports = [
    ../../profiles/common/opi5/hardware.nix
  ];
  atro.disko = {
    hostId = "5511171b";
    drives = [
      "nvme-Corsair_MP600_MINI_A936B52200CFWZ"
    ];
  };
}
