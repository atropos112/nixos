{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../lib/common/desktop
  ];
  topology.self = {
    interfaces = {
      eth0.network = "GIANT";
      tailscale0.addresses = ["giant"];
    };
    hardware.info = "i9-12900K, 64GB (DDR5), RTX3090";
  };

  networking = {
    hostName = "giant";
    interfaces.eth0.macAddress = "d8:bb:c1:a2:63:bd";
  };

  services.syncthing = {
    settings = {
      devices = {
        surface = {
          addresses = [
            "tcp://surface"
          ];
          autoAcceptFolders = false; # Can't auto accept as those will be overridden by the config below
          id = "UWJRHPP-IDPIB5H-W2PZTLG-7NN2RNU-HCV54T5-4LY64YB-NYQX7W3-JRHNGAS";
        };
      };
      folders.sync.devices = ["surface"]; # Adds to already existing devices
    };
  };

  systemd = {
    # Disabling all USB power management otherwise the PC can't suspend.
    services = {
      wakeonusb = {
        description = "Set all usb's to WakeOn Disabled";
        after = ["network.target" "sound.target"];
        wantedBy = ["default.target"];
        script = with pkgs; ''
          ${coreutils}/bin/echo disabled | ${coreutils}/bin/tee /sys/bus/usb/devices/*/power/wakeup
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    super-slicer-beta
    nvitop
    ollama-cuda
  ];

  powerManagement = {
    enable = true;
    # WARN: There is a bug in 6.12 that makes igc module not load when resuming from suspend
    # igc is the driver for the 2.5G ethernet card on the motherboard so this means no internet
    # This is a workaround to fix that, I unload it (in case it's loaded and in bad state) and then load it.
    resumeCommands = ''
      ${pkgs.kmod}/bin/modprobe -r igc
      ${pkgs.kmod}/bin/modprobe igc
      ${pkgs.networkmanager}/bin/nmcli networking on
      ${pkgs.networkmanager}/bin/nmcli connection up eth0
    '';
  };

  atro.hyprland.settings = [
    {
      priority = 1;
      value = {
        exec-once = [
          # To adjust the bus so that screen sharing work with pipewire
          "sleep 3 && systemctl restart --user xdg-desktop-portal-hyprland.service pipewire.service wireplumber.service" # hack to make screen sharing work with nvidia
          "xrandr --output DP-5 --primary" # Letting lutris and other xwayland apps know this is primary
          "element-desktop --disable-gpu"
          "signal-desktop"
          "sleep 3 && zapzap" # hack to make sure zapzap loads the config...
        ];

        monitor = [
          "DP-5,2560x1440@240,0x270,1"
          "DP-4,2560x1440@144,2560x270,1"
          "HDMI-A-5,1920x1080@75,5120x0,1,transform,3"
        ];

        workspace = [
          "1, monitor:DP-5, default:true"
          "2, monitor:DP-5, default:true"
          "3, monitor:DP-5, default:true"
          "4, monitor:DP-4, default:true"
          "5, monitor:DP-4, default:true"
          "6, monitor:DP-4, default:true"
          "7, monitor:DP-4, default:true"
          "8, monitor:HDMI-A-5, default:true"
          "9, monitor:HDMI-A-5, default:true"
          "10, monitor:HDMI-A-5, default:true"
        ];

        bind = [
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "CTRL_SHIFT_ALT, 1, movetoworkspace, 1"
          "CTRL_SHIFT_ALT, 2, movetoworkspace, 2"
          "CTRL_SHIFT_ALT, 3, movetoworkspace, 3"
          "CTRL_SHIFT_ALT, 4, movetoworkspace, 4"
          "CTRL_SHIFT_ALT, 5, movetoworkspace, 5"
          "CTRL_SHIFT_ALT, 6, movetoworkspace, 6"
          "CTRL_SHIFT_ALT, 7, movetoworkspace, 7"
          "CTRL_SHIFT_ALT, 8, movetoworkspace, 8"
          "CTRL_SHIFT_ALT, 9, movetoworkspace, 9"
          "CTRL_SHIFT_ALT, 0, movetoworkspace, 10"
        ];
      };
    }
  ];

  home-manager.users.atropos.programs.waybar = {
    settings = {
      mainBar = {
        network = {
          interface = "eth0";
        };
      };
    };
  };
}
