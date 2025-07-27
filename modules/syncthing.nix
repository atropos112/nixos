{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption mapAttrs filterAttrs hasAttr filter;
  inherit (lib.types) str attrsOf submodule listOf package nullOr bool enum;
  inherit (config.networking) hostName;
  cfg = config.atro.syncthing;

  homeDir =
    if cfg.userName == "root"
    then "/root"
    else "/home/${cfg.userName}";

  deviceEnabled = deviceName:
  # Device is not defined in the devices list (external device)
    !hasAttr deviceName cfg.devices
    # Device is set to true by the user
    || cfg.devices."${deviceName}" == true
    # Device is left as null (not set by the user) and hostname does not match the device name
    || (cfg.devices."${deviceName}".enable == null && deviceName != hostName);
in {
  options.atro.syncthing = {
    enable = mkEnableOption "hyprland setup";
    userName = mkOption {
      type = str;
      description = "The user to run syncthing as.";
    };
    secrets = {
      certPath = mkOption {
        type = str;
        default = "syncthing/${hostName}/cert";
        description = "SopsNix path to the certificate for syncthing.";
      };
      keyPath = mkOption {
        type = str;
        default = "syncthing/${hostName}/key";
        description = "SopsNix path to the key for syncthing.";
      };
    };
    devices = mkOption {
      type = attrsOf (submodule {
        options = {
          address = mkOption {
            type = str;
            description = "Address to connect to the device.";
          };
          id = mkOption {
            type = str;
            description = "Device ID for syncthing.";
          };
          enable = mkOption {
            type = nullOr bool;
            default = null;
            description = ''
              Whether to enable this device.

              If not set, the device will be enabled by default unless it has a name matching the hostname.

              If a device is set to `false` it will be excluded from folders.devices lists.
            '';
          };
        };
      });
      description = "Syncthing devices to connect to.";
    };
    folders = mkOption {
      type = attrsOf (submodule {
        options = {
          path = mkOption {
            type = str;
            description = "Path to the folder to sync.";
          };
          devices = mkOption {
            type = listOf str;
            description = "List of device names to sync with.";
          };
          id = mkOption {
            type = nullOr str;
            default = null;
            description = "ID of the folder, used to identify it in syncthing.";
          };
          type = mkOption {
            default = "sendreceive";
            description = "Type of the folder sync.";
            type = enum [
              "sendreceive"
              "sendonly"
              "receiveonly"
              "receiveencrypted"
            ];
          };
        };
      });
      description = ''
        Syncthing folders to sync.

        Do note if the device you are deploying this module to is not in the list it won't have that folder.

        Device names are done via hostnames, please do not change them in UI.
      '';
    };
    gui = {
      address = mkOption {
        type = str;
        default = "127.0.0.1:8384";
        description = "Address to bind the syncthing GUI to.";
      };
      userName = mkOption {
        type = str;
        default = cfg.userName;
        description = "Username for the syncthing GUI.";
      };
      password = mkOption {
        type = str;
        description = "Password for the syncthing GUI. The password must be a bcrypt hash.";
      };
    };
    package = mkOption {
      type = package;
      default = pkgs.syncthing;
      description = "The syncthing package to use.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "${cfg.secrets.certPath}" = {
        owner = config.users.users."${cfg.userName}".name;
        group = config.users.users."${cfg.userName}".name;
        mode = "0600";
      };
      "${cfg.secrets.keyPath}" = {
        owner = config.users.users."${cfg.userName}".name;
        group = config.users.users."${cfg.userName}".name;
        mode = "0600";
      };
    };

    atro.fastfetch.modules = [
      {
        priority = 1001;
        value = {
          "type" = "command";
          "text" = "systemctl is-active syncthing";
          "key" = "Syncthing";
        };
      }
    ];

    services.syncthing = {
      enable = true;
      package = cfg.package;
      # Run syncthing first time without the keys, they will appear in .config/syncthing then copy them over and then enable the below to keep them "forever"
      cert = config.sops.secrets."${cfg.secrets.certPath}".path;
      key = config.sops.secrets."${cfg.secrets.keyPath}".path;
      overrideDevices = true;
      overrideFolders = true;
      configDir = "${homeDir}/.config/syncthing";
      user = cfg.userName;
      systemService = true;
      guiAddress = cfg.gui.address;
      settings = {
        gui = {
          theme = "black"; # Why would you use anything else?
          password = cfg.gui.password;
          user = cfg.gui.userName;
          insecureSkipHostcheck = true;
        };
        options = {
          urAccepted = -1;
        };
        devices =
          cfg.devices
          |> filterAttrs (name: _: deviceEnabled name)
          |> mapAttrs (_: device: {
            addresses = [device.address];
            autoAcceptFolders = false;
            id = device.id;
          });

        folders =
          cfg.folders
          |> filterAttrs (_: folder: builtins.elem hostName folder.devices)
          |> mapAttrs (name: folder: {
            enable = true;
            id =
              if folder.id == null
              then name
              else folder.id;
            path = folder.path;
            type = folder.type;
            devices = folder.devices |> filter deviceEnabled;
          });
      };
    };
  };
}
