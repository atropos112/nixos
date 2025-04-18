{pkgs, ...}: {
  home-manager.users.atropos.programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    # WARN: They waybar flake version (0.12.0+date=2025-02-21_8490a1d) is broken using nixpkgs one instead
    # package = inputs.waybar.packages.${pkgs.system}.waybar;
    style = builtins.readFile ./style.css;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        exclusive = true;
        passthrough = false;
        "gtk-layer-shell" = true;
        height = 30;
        "modules-left" = [
          "clock"
          "hyprland/window"
        ];
        "modules-center" = [
          "hyprland/workspaces"
        ];
        "modules-right" = [
          "cpu"
          "temperature"
          "memory"
          "custom/power_profile"
          "battery"
          "pulseaudio"
          "idle_inhibitor"
          "bluetooth"
          "network"
          "tray"
        ];
        "hyprland/window" = {
          format = "{}";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        cpu = {
          interval = 1;
          format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
          "format-icons" = [
            "<span color='#69ff94'>▁</span>"
            "<span color='#2aa9ff'>▂</span>"
            "<span color='#f8f8f2'>▃</span>"
            "<span color='#f8f8f2'>▄</span>"
            "<span color='#ffffa5'>▅</span>"
            "<span color='#ffffa5'>▆</span>"
            "<span color='#ff9977'>▇</span>"
            "<span color='#dd532e'>█</span>"
          ];
        };

        memory = {
          interval = 10;
          format = "{used:0.1f}G ";
        };
        tray = {
          "icon-size" = 15;
          spacing = 10;
        };
        clock = {
          format = "{:%H:%M}  ";
          "format-alt" = "{:%A, %B %d, %Y (%R)}  ";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            "on-click-right" = "mode";
            "on-click-forward" = "tz_up";
            "on-click-backward" = "tz_down";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          "format-icons" = ["󰃞" "󰃟" "󰃠"];
          "on-scroll-up" = "brightnessctl set 1%+";
          "on-scroll-down" = "brightnessctl set 1%-";
          "min-length" = 6;
        };
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "format-plugged" = " {capacity}%";
          "format-alt" = "{time} {icon}";
          "format-icons" = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };
        temperature = {
          "thermal-zone" = 2;
          "hwmon-path" = [
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp2_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp3_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp4_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp5_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp6_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp7_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp8_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp9_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp10_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp1_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp2_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp3_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp4_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp5_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp6_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp7_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp8_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp9_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon8/temp10_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp2_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp3_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp4_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp5_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp6_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp7_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp8_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp9_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp10_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon7/temp1_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon7/temp2_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon7/temp3_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon7/temp4_input"
            "/sys/devices/platform/coretemp.0/hwmon/hwmon7/temp5_input"
          ];
          "critical-threshold" = 80;
          "format-critical" = "{temperatureC}°C ";
          format = "{temperatureC}°C ";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          tooltip = false;
          "format-muted" = " Muted";
          "on-click" = "pamixer -t";
          "on-scroll-up" = "pamixer -i 5";
          "on-scroll-down" = "pamixer -d 5";
          "scroll-step" = 5;
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" "" ""];
          };
        };
        "pulseaudio#microphone" = {
          format = "{format_source}";
          "format-source" = "Mic: {volume}%";
          "format-source-muted" = "Mic: Muted";
          "on-click" = "pamixer --default-source -t";
          "on-scroll-up" = "pamixer --default-source -i 5";
          "on-scroll-down" = "pamixer --default-source -d 5";
          "scroll-step" = 5;
        };
        network = {
          # "interface" = "eth0";
          "format" = "{ifname}";
          "format-wifi" = "D:{bandwidthDownBytes} U:{bandwidthUpBytes}";
          "format-ethernet" = "D:{bandwidthDownBytes} U:{bandwidthUpBytes}";
          "interval" = 2;
          "tooltip-format" = "{essid} - {ipaddr}/{cidr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}:{essid} {ipaddr}/{cidr}";
          "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
          "tooltip-format-ethernet" = "{ifname} ";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 50;
        };
        bluetooth = {
          "format" = " {status}";
          "format-disabled" = "";
          "format-connected" = " {num_connections}";
          "tooltip-format" = "{device_alias}";
          "tooltip-format-connected" = " {device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}";
        };
        "hyprland/workspaces" = {
          format = "{name}: {icon}";
          "format-icons" = {
            active = "";
            default = "";
          };
        };
      };
    };
  };
}
