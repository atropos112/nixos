{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../lib/common/desktop
  ];

  topology.self = {
    interfaces = {
      wifi = {
        network = "WLAN";
        type = "wifi";
      };
      tailscale0.addresses = ["surface"];
    };
    hardware.info = "i7-8650U, 16GB, GTX1060";
  };
  powerManagement.enable = true;
  networking.hostName = "surface";

  environment.persistence."/persistent" = {
    # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
    directories = [
      "/etc/NetworkManager/system-connections" # To store wifi passwords/connections  TODO: Figure out a way to generate this.
    ];
  };

  systemd = {
    # This service sets all usb ports to wakeon so that a key press can get out of suspended state
    services.wakeonusb = {
      description = "Set all usb's to WakeOn Enabled";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      script = with pkgs; ''
        ${coreutils}/bin/echo enabled | ${coreutils}/bin/tee /sys/bus/usb/devices/*/power/wakeup
      '';
    };

    services.fusuma = {
      description = "Trackpad Gestures";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      script = with pkgs; ''
        ${fusuma}/bin/fusuma
      '';
    };
  };

  services = {
    # vpn mesh to connect to other devices
    tailscale = {
      extraUpFlags = [
        "--accept-routes"
      ];
    };

    # To provide information about the battery (e.g. how much % is left)
    upower = {
      enable = true;
    };

    # IX Server does a lot, used for keyboard settings here and to select the display manager (Login screen)
    # Note, the keyboard settings are for stuff it controls like GDM, onced logged in, DE (e.g. HyprLand) takes over and that can dictate the keyboard.
    xserver.xkb = {
      layout = "us,us";
      variant = "colemak,intl";
      options = "grp:win_space_toggle";
    };
  };

  environment.systemPackages = with pkgs; [
    # trackpad gestures
    fusuma
  ];

  atro.hyprland.deviceSpecificSettings = {
    monitor = [
      "eDP-1,3240x2160@60,0x0,1.8,bitdepth,10"
      "DP-2,1440x900@60,1800x0,1.0,bitdepth,10" # monitor in Stoke
    ];

    workspace = [
      "1, monitor:eDP-1, default:true"
      "2, monitor:eDP-1, default:true"
      "3, monitor:eDP-1, default:true"
      "4, monitor:eDP-1, default:true"
      "5, monitor:eDP-1, default:true"
      "6, monitor:DP-2, default:true"
      "7, monitor:DP-2, default:true"
      "8, monitor:DP-2, default:true"
      "9, monitor:DP-2, default:true"
      "10, monitor:DP-2, default:true"
    ];
    bind = [
      # Move active window to a workspace with mainMod + shift + [0-9]
      "SUPER_SHIFT, 1, movetoworkspace, 1"
      "SUPER_SHIFT, 2, movetoworkspace, 2"
      "SUPER_SHIFT, 3, movetoworkspace, 3"
      "SUPER_SHIFT, 4, movetoworkspace, 4"
      "SUPER_SHIFT, 5, movetoworkspace, 5"
      "SUPER_SHIFT, 6, movetoworkspace, 6"
      "SUPER_SHIFT, 7, movetoworkspace, 7"
      "SUPER_SHIFT, 8, movetoworkspace, 8"
      "SUPER_SHIFT, 9, movetoworkspace, 9"
      "SUPER_SHIFT, 0, movetoworkspace, 10"
    ];
    input = {
      # These are duplicating what in nix configuration make sure you keep them in sync.
      kb_layout = "us,us";
      kb_variant = "colemak,intl";
      kb_model = "";
      kb_options = [
        "grp:win_space_toggle"
        "caps:swapescape" # On giant this os done through moonlander already.
      ];
      kb_rules = "";
    };
  };
}
