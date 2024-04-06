_: {
  imports = [
    ../modules/hyprland.nix
  ];
  # Implements the module basesettings etc.

  atro.hyprland = {
    enable = true;
    baseSettings = {
      exec-once = [
        # Autostart
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swww init"

        # Start services
        "systemctl start --user waybar.service && sleep 2 && systemctl restart --user waybar.service"
        "systemctl start --user swayidle.service"
        "systemctl enable --now --user avizo.service"
        "systemctl restart --user kopia-backup.service"

        # Start applications
        "tailscale-systray"
        "copyq --start-server"
        "element-desktop --disable-gpu"
      ];

      bind = [
        "$mainMod, o, togglefloating"
        "$mainMod, j, fullscreen"
        "$mainMod, b, exec, systemctl --user is-active waybar.service &> /dev/null && systemctl --user stop waybar.service || systemctl --user start waybar.service"
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, Y, exec, element-desktop --disable-gpu"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "Alt_L, Z, exec, copyq show"
        "$mainMod, Z, exec, copyq show"
        "$mainMod, X, exec, wlogout"
        "$mainMod, V, exec, pavucontrol"
        "$mainMod, C, exec, blueman-manager"
        "$mainMod, P, exec, grimshot --notify --cursor copy area"
        "$mainMod, W, exec, vivaldi  --force-dark-mode --enable-features=WebUIDarkMode --use-gl=egl"
        "$mainMod, T, exec, kitty nvim"
        "$mainMod, L, exec, systemctl suspend"
        "$mainMod, F, exec, nautilus"
        "$mainMod, R, exec, tofi-drun --drun-launch=true --font=/home/atropos/media/fonts/ComicCodeLigatures-Regular.ttf --late-keyboard-init=true --ascii-input=true"
        "$mainMod, J, togglesplit,"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      binde = [
        # brightness
        ", XF86MonBrightnessUp, exec, lightctl up 5"
        ", XF86MonBrightnessDown, exec, lightctl down 5"

        # volume
        ", XF86AudioRaiseVolume, exec, volumectl -u up 5"
        ", XF86AudioLowerVolume, exec, volumectl -u down 5"
        ", XF86AudioMute, exec, volumectl toggle-mute"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      general = {
        gaps_in = 2;
        gaps_out = 0;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 5;

        # power hungry according to FAQ
        blur = {
          enabled = false;
          size = 5;
          passes = 1;
        };

        # power hungry according to FAQ
        drop_shadow = false;

        shadow_range = 4;
        shadow_render_power = 3;
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 3, myBezier"
          "windowsOut, 1, 3, default, popin 80%"
          "border, 1, 4, default"
          "borderangle, 1, 3, default"
          "fade, 1, 4, default"
          "workspaces, 1, 2, default"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
        vfr = true;
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = false;
      };

      "$mainMod" = "SUPER";

      input = {
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          natural_scroll = false;
        };
      };
    };
  };
}
