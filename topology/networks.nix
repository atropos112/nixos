{
  config,
  lib,
  ...
}: let
  inherit (config.lib.topology) mkInternet mkConnection mkSwitch mkRouter;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.strings) splitString;
  inherit (lib) elemAt;
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
    TAILSCALE = {
      name = "TAILSCALE";
      cidrv4 = "100.0.0.0/8";
    };
  };

  nodes =
    # mapping plugs
    mapAttrs (name: v: {
      inherit name;
      deviceType = "device";
      hardware.info =
        if (elemAt (splitString "-" name) 0) == "shelly"
        then "Shelly Plus Plug"
        else "TP-Link Tapo P110 Plug";
      interfaces = {
        wifi = {
          network = "WLAN";
          type = "wifi";
          addresses = [v.ip];
        };
      };
    }) {
      shellly-giant.ip = "9.0.0.234";
      shelly-rzr.ip = "9.0.0.235";
      shelly-a21.ip = "9.0.0.236";
      shelly-smol.ip = "9.0.0.237";
      shelly-opis.ip = "9.0.0.238";
      tapo-ap.ip = "9.0.0.239";
      tapo-pikvm.ip = "9.0.0.240";
      tapo-switch.ip = "9.0.0.241";
      tapo-printer.ip = "9.0.0.242";
    }
    # The rest
    // {
      internet = mkInternet {
        connections = mkConnection "router" "igc0";
      };

      op8p = {
        name = "p9pf";
        deviceType = "device";
        hardware.info = "Pixen 9 Pro Fold";
        interfaces = {
          wifi = {
            network = "WLAN";
            addresses = ["9.0.0.230"];
            type = "wifi";
          };
          tailscale0 = {
            network = "TAILSCALE";
            type = "wireguard";
            virtual = true;
            addresses = ["p9pf"];
          };
        };
      };

      vacuum = {
        name = "vacuum";
        deviceType = "device";
        hardware.info = "Dreame L10 Pro";
        interfaces = {
          wifi = {
            network = "WLAN";
            addresses = ["9.0.0.232"];
            type = "wifi";
          };
        };
      };

      switch = mkSwitch "Switch" {
        info = ''
          Ports: 8 x 10 Gbps
          Make: Tp-link TL-ST1008/2008
        '';
        image = ./pictures/tplink-switch.png;
        interfaceGroups = [["1" "2" "3" "4" "5" "6" "7" "8"]];
        interfaces = {
          # These addresses are defined on the "other" side of the connection (better rendering that way)
          "1" = {
            network = "LAN";
            # addresses = ["9.0.0.8"];
          };
          "2" = {
            network = "LAN";
            # addresses = ["9.0.0.5"];
          };
          "3" = {
            network = "LAN";
            # addresses = ["9.0.0.7"];
          };
          "4" = {
            network = "LAN";
            # addresses = ["9.0.0.6"];
          };
          "5" = {
            network = "LAN";
            # addresses = ["9.0.0.2"];
          };
          "6" = {
            network = "LAN";
            # addresses = ["9.0.0.3"];
          };
          "7" = {
            network = "LAN";
            # addresses = ["9.0.0.4"];
          };
          "8" = {
            network = "LAN";
            addresses = ["9.0.0.11"];
          };
        };
        connections = {
          "1" = mkConnection "opi4" "eth0";
          "2" = mkConnection "opi1" "eth0";
          "3" = mkConnection "opi3" "eth0";
          "4" = mkConnection "opi2" "eth0";
          "5" = mkConnection "atrorzr" "eth0";
          "6" = mkConnection "a21" "eth0";
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
          "2" = {
            network = "WLAN";
            addresses = ["9.0.0.254"];
          };
          "3" = {
            network = "WLAN";
            addresses = ["9.0.0.253"];
          };
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
        hardware.info = "BCM2711, 4GB, Raspberry Pi 4";
        interfaces = {
          eth0 = {
            network = "WLAN";
            addresses = ["9.0.0.253"];
          };
          tailscale0 = {
            network = "TAILSCALE";
            addresses = ["100.93.142.121" "pikvm"];
            type = "wireguard";
            virtual = true;
          };
        };
      };

      router = mkRouter "Router" {
        info = ''
          i3-N305, 32 GB RAM (LPDDR5), 3 x 2.5 Gbps, 2 x 25 Gbps
        '';
        image = ./pictures/r86s-router.png;
        interfaceGroups = [
          ["igc0"]
          ["igc1"]
          ["igc2"]
          ["mce0"]
          ["mce1"]
        ];

        interfaces = {
          igc0 = {
            network = "WAN";
            addresses = ["redacted"];
          };
          igc1 = {
            network = "GIANT";
            addresses = ["9.0.0.150"];
          };
          igc2 = {
            network = "WLAN";
            addresses = ["9.0.0.200"];
          };
          mce1 = {
            network = "LAN";
            addresses = ["9.0.0.1"];
          };
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
