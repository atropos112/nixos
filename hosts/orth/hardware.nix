_: {
  imports = [
    ../../profiles/impermanence/basic.nix
  ];

  atro = {
    boot.enable = true;

    disko = {
      enable = true;
      hostId = "1676722a";
      mode = "raidz1";
      drives = [
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003099P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003317P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003360P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003472P111D"
      ];
    };
  };
}
