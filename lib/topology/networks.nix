{config, ...}: let
  inherit (config.lib.topology) mkInternet mkConnection mkSwitch mkRouter;
in {
  networks = {
    WAN = {
      name = "WAN";
      cidrv4 = "redacted";
    };
    GIANT = {
      name = "GIANT";
      cidrv4 = "9.0.0.150/26";
    };
    LAN = {
      name = "LAN";
      cidrv4 = "9.0.0.1/25";
    };
    WLAN = {
      name = "WLAN";
      cidrv4 = "9.0.0.200/26";
    };
  };

  nodes = {
    internet = mkInternet {
      connections = mkConnection "router" "WAN";
    };

    op8p = {
      name = "op8p";
      deviceType = "Android phone";
      hardware.info = "OnePlus 8 Pro";
    };

    switch = mkSwitch "Switch" {
      info = ''
        Ports: 8 x 10 Gbps
        Make: Tp-link TL-ST1008/2008
      '';
      image = ./pictures/tplink-switch.png;
      interfaceGroups = [["1" "2" "3" "4" "5" "6" "7" "8"]];
      interfaces = {
        "1".network = "LAN";
        "2".network = "LAN";
        "3".network = "LAN";
        "4".network = "LAN";
        "5".network = "LAN";
        "6".network = "LAN";
        "7".network = "LAN";
        "8".network = "LAN";
      };
      connections = {
        "1" = mkConnection "atroopi4" "eth0";
        "2" = mkConnection "atroopi1" "eth0";
        "3" = mkConnection "atroopi3" "eth0";
        "4" = mkConnection "atroopi2" "eth0";
        "5" = mkConnection "atrorzr" "eth0";
        "6" = mkConnection "atroa21" "eth0";
        "7" = mkConnection "atrosmol" "eth0";
        "8" = mkConnection "router" "mce1";
      };
    };

    wap = mkSwitch "Wireless Access Point" {
      info = ''
        Ports: 5 x 1 Gbps
        Make: Netgear R8000
      '';
      image = ./pictures/r8000.png;
      interfaceGroups = [["1" "2" "3" "4" "5"]];
      interfaces = {
        "1".network = "WLAN";
        "2".network = "WLAN";
        "3".network = "WLAN";
        "4".network = "WLAN";
        "5".network = "WLAN";
      };
      connections = {
        "2" = mkConnection "router" "igc2";
        "3" = mkConnection "pikvm" "eth0";
      };
    };

    pikvm = {
      name = "pikvm";
      deviceType = "device";
      hardware.info = "CPU: BCM2711, RAM: 4GB, Make: Raspberry Pi 4";
      interfaces.eth0.network = "WLAN";
    };

    router = mkRouter "Router" {
      info = ''
        CPU: i3-N305, RAM: 32 GB RAM (LPDDR5), PORTS: 3 x 2.5 Gbps, 2 x 25 Gbps
      '';
      image = ./pictures/r86s-router.png;
      interfaceGroups = [["igc0" "igc1" "igc2" "mce0" "mce1"]];

      interfaces = {
        igc0.network = "WAN";
        igc1.network = "GIANT";
        igc2.network = "WLAN";
        mce1.network = "LAN";
      };
      connections = {
        igc0 = mkConnection "internet" "*";
        igc1 = mkConnection "giant" "eth0";
        igc2 = mkConnection "wap" "2";
        mce1 = mkConnection "switch" "8";
      };
    };
  };
}
