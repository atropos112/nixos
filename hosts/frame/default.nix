_: {
  imports = [
    ./hardware.nix
    ../../profiles/common/laptop.nix
    ../../profiles/services/syncthing.nix
    ../../profiles/networking/dns/remote.nix
  ];

  topology.self = {
    interfaces = {
      wifi = {
        network = "WLAN";
        type = "wifi";
      };
      tailscale0.addresses = ["frame"];
    };
    hardware.info = "Ryzen AI 5 340, 32GB";
  };
  powerManagement.enable = true;

  users = {
    groups.fwupd-refresh.gid = 988;
    users.fwupd-refresh = {
      uid = 996;
      group = "fwupd-refresh";
    };
  };

  networking = {
    hostName = "frame";
    # Its not really ethernet its wifi.
    # interfaces.eth0.macAddress = "";
  };

  environment.persistence."/persistent" = {
    # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
    directories = [
      "/var/lib/fprint"
    ];
  };

  # INFO: To register a fingerprint run `sudo fprintd-enroll <username>`
  # This will save data to /var/lib/fprint , if doing persistence you will need to persist that
  services.fprintd.enable = true; # Already enabled by nixos hardware but wanted to be explicit

  home-manager.users.atropos.programs.waybar.settings.mainBar.network.interface = "wlan0";

  atro.kopia.networkInterface = "wlan0";

  atro.hyprland.settings = [
    {
      priority = 1;
      value = {
        monitor = [
          "eDP-1,2880x1920@120,0x0,1.5,bitdepth,10" # main monitor
          "DP-2,1440x900@60,1920x0,1,bitdepth,10" # monitor in Stoke
          # "DP-1,1920x1080@60,1800x0,1.0,bitdepth,10" # monitor in Ndg
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
  ];
}
