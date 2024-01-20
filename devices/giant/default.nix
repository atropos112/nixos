{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../lib/common/desktop
  ];

  networking.hostName = "giant";

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

  atro.hyprland.deviceSpecificSettings = {
    monitor = [
      "HDMI-A-5,1920x1080@75,0x0,1,transform,1,bitdepth,10"
      "DP-5,2560x1440@240,1080x480,1,bitdepth,10"
      "DP-4,2560x1440@144,3640x0,1,transform,3,bitdepth,10"
    ];

    workspace = [
      "1, monitor:HDMI-A-5, default:true"
      "2, monitor:HDMI-A-5, default:true"
      "3, monitor:HDMI-A-5, default:true"
      "4, monitor:DP-5, default:true"
      "5, monitor:DP-5, default:true"
      "6, monitor:DP-5, default:true"
      "7, monitor:DP-5, default:true"
      "8, monitor:DP-4, default:true"
      "9, monitor:DP-4, default:true"
      "10, monitor:DP-4, default:true"
    ];
  };
}
