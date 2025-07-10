{
  config,
  lib,
  ...
}: let
  inherit (config.networking) hostName;
  inherit (lib) mapAttrs;

  inherit (import ../utils/priorityList.nix {inherit lib;}) listToPriorityList;

  deviceNameToHostName = deviceName:
    if deviceName == "cluster"
    then "tcp://syncthing"
    else "tcp://${deviceName}";
in {
  /*
  To add a new device you will need cert, key and device ID.
  To get all of those do
  ```bash
  nix-shell -p syncthing --run "syncthing -generate /tmp/syncthing"
  ```
  You can now find key, cert and config.xml (containing device ID) in /tmp/syncthing.
  */
  atro = {
    syncthing = {
      enable = true;
      userName = "atropos";
      secrets = {
        certPath = "syncthing/${hostName}/cert";
        keyPath = "syncthing/${hostName}/key";
      };
      gui = {
        address = "0.0.0.0:8384"; # I used login and password and don't expose it to the internet
        password = "$2y$12$8NqZv2uGypWM9AfQRoklbeEMZ2wmtPlSdkCu4tkE73VkiYzAXHdg2"; # bcrypt hash of the real password which is in BitWarden
      };

      folders = {
        manual = {
          devices = ["p9pf" "surface" "giant" "atrorzr"];
          path = "/home/atropos/Sync/manual";
        };
        websites = {
          devices = ["cluster" "p9pf" "surface"];
          path = "/home/atropos/Sync/websites";
        };
      };

      devices =
        {
          cluster = "ZLCZ4HZ-E67BWUS-5VLRQ5M-PIA4JJW-DMBVDZH-EMOF5AM-S5R6QE7-IMXBEA2";
          p9pf = "ZSU4XYD-YTVHULA-UPB43OX-HABOH37-3QSDCYJ-56TGMCQ-IWR73HI-DXKCJAF";
          surface = "UWJRHPP-IDPIB5H-W2PZTLG-7NN2RNU-HCV54T5-4LY64YB-NYQX7W3-JRHNGAS";
          giant = "TI3JVQU-MP36YWD-3MAIGC5-FYN4DQI-QFZPF5V-YC5IW25-55DEQIC-NMG77AL";
          atrorzr = "HBYTR3Y-VO3BX62-M4TX7IW-COBUIPN-FYDVFPB-P76WM4U-E4DYTEH-32FFXQO";
        }
        |> mapAttrs (name: deviceId: {
          id = deviceId;
          address = deviceNameToHostName name;
        });
    };

    fastfetch.modules = listToPriorityList 1000 [
      {
        "type" = "command";
        "text" = "systemctl is-active syncthing";
        "key" = "Syncthing";
      }
      "separator" # Displays
      "display"
    ];
  };
}
