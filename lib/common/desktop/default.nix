{
  pkgs,
  lib,
  ...
}: let
  homeUser = "atropos";
  homeDirectory = "/home/${homeUser}";
in {
  imports = [
    ../default.nix
    ../kubernetes/user.nix
    ../../pkgs/foot.nix
    ../../pkgs/vscode.nix
    ../../pkgs/hyprland.nix
    ../../pkgs/zfs.nix
    ../../modules/kopia.nix
    ../../pkgs/syncthing.nix
    ../../pkgs/waybar
    ../../pkgs/copyq
    ../../pkgs/mako.nix
    ../../pkgs/tofi
  ];

  # Linking fonts. This is a hack to get around the fact that the fonts are in a different place than the system expects.
  # system.activationScripts.usrlocalbin = ''
  #   mkdir -m 0755 -p /usr/local
  #   ln -nsf /home/atropos/media/fonts /home/atropos/.local/share/fonts
  # '';

  atro.kopia.enable = true;

  # Networking basics (hostname excluded)
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };

  virtualisation.docker = {
    storageDriver = "zfs";
  };

  hardware = {
    # OpenGL acceleration
    opengl.enable = true;

    # Bluetooth support
    bluetooth.enable = true;
  };

  environment.sessionVariables = {
    # To Globally replace gcc stuff use this env var but it will do damage to othre stuff so ideally use nix-ld approach
    LD_LIBRARY_PATH = lib.mkForce "${pkgs.stdenv.cc.cc.lib}/lib";

    # hint XDG to use wayland
    XDG_SESSION_TYPE = "wayland";

    # hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";

    # Inform all GDK apps its wayland env
    GDK_BACKEND = "wayland";

    # Inform QT apps of the version
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Base
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Hyprland scaling
    GDK_SCALE = "1";
    XCURSOR_SIZE = "24";
  };

  security = {
    rtkit.enable = true; # Recomended for pipewire
    pam.services = {
      gdm.enableGnomeKeyring = true; # To make the keyring work, for things like github copilot
      swaylock = {}; # To make swaylock respect my password
    };
  };

  services = {
    udev = {
      enable = true; # default anyway
      extraRules = ''
        # Rules for Oryx web flashing and live training
        KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
        KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

        # Legacy rules for live training over webusb (Not needed for firmware v21+)
          # Rule for all ZSA keyboards
          SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
          # Rule for the Moonlander
          SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
          # Rule for the Ergodox EZ
          SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
          # Rule for the Planck EZ
          SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

        # Wally Flashing rules for the Ergodox EZ
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

        # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
        # Keymapp Flashing rules for the Voyager
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
      '';
    };

    # For sound to work
    pipewire = {
      wireplumber.enable = true; # This is the default, wanted to make it explicit.
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth manager
    blueman.enable = true;

    # For power usage settings, what governor when, what cpu freq etc.
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        USB_AUTOSUSPEND = 1;
        USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 0;
      };
    };

    # For security purposes some apps (e.g. github copilot) require keyring.
    gnome.gnome-keyring.enable = true;

    # IX Server does a lot, used for keyboard settings here and to select the display manager (Login screen)
    # Note, the keyboard settings are for stuff it controls like GDM, onced logged in, DE (e.g. HyprLand) takes over and that can dictate the keyboard.
    xserver = {
      enable = true;
      # Display manager (Login screen)
      displayManager = {
        autoLogin = {
          enable = false; # I want to type my password as I may come remotely.
          user = "atropos";
        };
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };

    # For XDG portals to work
    dbus.enable = true;
  };

  programs = {
    # Helps with libc problems with sqlalchemy, https://discourse.nixos.org/t/sqlalchemy-python-fails-to-find-libstdc-so-6-in-virtualenv/38153
    # Have to add the following to shell.nix to make it work:
    # with import <nixpkgs> {};
    # mkShell {
    #   NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    #     stdenv.cc.cc
    #   ];
    #   NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
    #   shellHook = ''
    #     export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    #   '';
    # }

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        zlib # numpy
        libgcc # sqlalchemy
      ];
    };

    # File manager, this is the GUI for file management.
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # Vivaldi is a web browser
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = false;
      commandLineArgs = [
        "--ozone-platform-hint=auto" # autodetect wayland or x11
      ];
    })
    vivaldi-ffmpeg-codecs
    widevine-cdm

    # Backup solution
    kopia

    # Wallpaper setter
    swww

    # Terminal
    # kitty

    # Interacts with the service to provide power usage information, e.g. how much battery is left.
    upower

    # To set/get screen brightness
    brightnessctl

    # Provide a "shutdown" window for GUI convinience
    wlogout

    # Provides controls for sound related matters
    pavucontrol

    # Python
    python311Full
    #(python311Full.withPackages packages)
    python312Full

    # Python package manager (Poetry)
    poetry

    # Polkit authentication for KDE based apps.
    # Authentication agents are the things that pop up a window asking you for a
    # password whenever an app wants to elevate its privileges.
    polkit-kde-agent

    # Application killer
    killall

    # Keyring needed for some applications (e.g. github copilot)
    libgnome-keyring

    # Javascript runtimes
    bun
    nodejs_20

    # Dotnet SDK
    dotnet-sdk_8
    dotnet-sdk_7
    dotnet-sdk # this is 6

    # Dotnet runtime
    dotnet-runtime_8
    dotnet-runtime_7
    dotnet-runtime # this is 6

    # Get CPU temps etc.
    lm_sensors

    # perf testing of a bash call or multiple functions
    hyperfine

    # Qogir theme
    qogir-theme
    qogir-icon-theme

    # GTK theme gui manager
    lxappearance # To run it use: GDK_BACKEND=x11 lxappearance

    # ProtonMail suite
    electron-mail

    # Music player
    spotify

    # Matrix client
    element-desktop-wayland

    # For better bluetooth controls
    bluez

    # QT provides a lot of the GUI stuff
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    qt6.qtwayland

    # Screenshoting tools
    # Need grim and slurp to use grimshot which does the screenshoting
    grim
    slurp
    sway-contrib.grimshot

    # Sound control via cli (used in bar, and for keyboard shortcuts)
    pamixer

    # CLI status of storage usage
    duf

    # Useful tool for finding large files to cut down on storage usage
    ncdu

    # Hack to deal with some apps not working on X
    xwayland

    # Lock screen
    swaylock-effects

    # Manages locking when suspending, timeout or other events happen.
    swayidle

    # Interacts with some apps to do correct copy n paste
    wl-clipboard

    # psql to connect to postgres databases
    postgresql

    # NIX LSP
    nil

    # Allows setting some global flags for applications to interpret, for example dark mode.
    dconf

    # Nice sys-tray for tailscale
    tailscale-systray

    # Provides power usage stats and some toggles
    powertop

    # Basic utils like echo and tee. Are available by default but stating it here explicitly to refer it in systemd services (like wakeonusb).
    coreutils

    # Watching video player
    vlc

    # Youtube (and more) downloader
    yt-dlp

    # Using pamixer (alt paactl) and brightlessctl (alt light) it also creates nice graphic demonstrating levels
    avizo

    # Allows to serve zim files which in turn provide offline (pre-downloaded) websites
    kiwix-tools

    # Golang package
    go_1_22

    # Torrent client
    transmission-gtk

    # Font viewer (have to open twice for some reason)
    gnome.gnome-font-viewer

    # Go LSP server
    gopls

    # Rust debbug server
    vscode-extensions.vadimcn.vscode-lldb.adapter

    # Multiplexer for terminal
    tmux

    # pdf viewer
    zathura

    # connect to k8s external secret source
    doppler

    # password manager
    bitwarden

    # dns resolving tool (for testing)
    dig

    # tool for partitioning
    parted

    # execution tool (in repos)
    just
    gnumake

    # hacky tool to simulate keyboard inputs
    wtype

    # C++ compiler
    gcc

    # proprietary chat client (for external usage)
    slack

    # database client
    dbeaver

    # debuger for golang
    delve

    # Cllium eBPF client tool for kubernetes cluster
    cilium-cli

    # deploying nix builds easily, to many machines at the same time even
    colmena

    #WIP
    hadolint
    czkawka
    gum
    ginkgo
    ocaml
    wpaperd
    pre-commit
    rustup
    argocd
    statix # to give suggestions on nix stuff
    deadnix # look for dead nix code
    alejandra
    usbimager # etcher equiv
    nvd # diff for nixos deploys
    iamb # terminal client for matix
  ];

  systemd = {
    # This is a service that allows you to control with bluetooth headphones (e.g. volume play/stop)
    user.services = {
      mpris-proxy = {
        description = "Mpris proxy";
        after = ["network.target" "sound.target"];
        wantedBy = ["default.target"];
        serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      };
    };
  };

  # Portals are a standardised framework allowing desktop applications to use resources outside of their sandbox.
  xdg.portal = {
    enable = true;
  };

  home-manager.users.atropos = {config, ...}: {
    home = {
      file = {
        "${homeDirectory}/.local/share/fonts" = {
          enable = true;
          recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "/home/atropos/media/fonts";
        };
      };

      sessionPath = [
        "$HOME/.bun/bin"
        "$HOME/media/bins"
        "$HOME/.go/bin"
      ];
    };

    services = {
      # For showing volume increases and brightness, etc.
      avizo = {
        enable = true;
        package = pkgs.avizo;
      };

      swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 1680; # 30min - 2 minutes
            command = "${pkgs.libnotify}/bin/notify-send -u 'low' 'Suspending and locking in 2 minutes...'";
          }
          {
            timeout = 1790; # 30min - 10seconds
            command = "${pkgs.libnotify}/bin/notify-send -u 'critical' 'Suspending and locking in 10 seconds...'";
          }
          {
            timeout = 1800; # 30min
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock-effects}/bin/swaylock";
          }
        ];
      };
    };

    programs = {
      # Wallpaper changer
      wpaperd = {
        enable = false;
        package = pkgs.wpaperd;
        settings = {
          "default" = {
            "path" = "${homeDirectory}/media/wallpapers";
            "duration" = "30m";
            "sorting" = "random";
          };
        };
      };

      # For locking the screen
      swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          "daemonize" = true;
          "show-failed-attempts" = true;
          "clock" = true;
          "screenshot" = true;
          "effect-blur" = "9x5";
          "effect-vignette" = "0.5:0.5";
          "color" = "1f1d2e80";
          "indicator" = true;
          "indicator-radius" = "200";
          "indicator-thickness" = "20";
          "line-color" = "1f1d2e";
          "ring-color" = "191724";
          "inside-color" = "1f1d2e";
          "key-hl-color" = "075870";
          "separator-color" = "00000000";
          "text-color" = "e0def4";
          "text-caps-lock-color" = "";
          "line-ver-color" = "075870";
          "ring-ver-color" = "075870";
          "inside-ver-color" = "1f1d2e";
          "text-ver-color" = "e0def4";
          "ring-wrong-color" = "31748f";
          "text-wrong-color" = "31748f";
          "inside-wrong-color" = "1f1d2e";
          "inside-clear-color" = "1f1d2e";
          "text-clear-color" = "e0def4";
          "ring-clear-color" = "9ccfd8";
          "line-clear-color" = "1f1d2e";
          "line-wrong-color" = "1f1d2e";
          "bs-hl-color" = "31748f";
          "datestr" = "%a %B %e";
          "timestr" = "%I:%M %p";
          "fade-in" = 0.2;
          "ignore-empty-password" = true;
          "font-size" = 32;
        };
      };

      zathura = {
        enable = true;
        package = pkgs.zathura;
        options = {
          notification-error-bg = "#ff5555"; # Red
          notification-error-fg = "#f8f8f2"; # Foreground
          notification-warning-bg = "#ffb86c"; # Orange
          notification-warning-fg = "#44475a"; # Selection
          notification-bg = "#282a36"; # Background
          notification-fg = "#f8f8f2"; # Foreground

          completion-bg = "#282a36"; # Background
          completion-fg = "#6272a4"; # Comment
          completion-group-bg = "#282a36"; # Background
          completion-group-fg = "#6272a4"; # Comment
          completion-highlight-bg = "#44475a"; # Selection
          completion-highlight-fg = "#f8f8f2"; # Foreground

          index-bg = "#282a36"; # Background
          index-fg = "#f8f8f2"; # Foreground
          index-active-bg = "#44475a"; # Current Line
          index-active-fg = "#f8f8f2"; # Foreground

          inputbar-bg = "#282a36"; # Background
          inputbar-fg = "#f8f8f2"; # Foreground
          statusbar-bg = "#282a36"; # Background
          statusbar-fg = "#f8f8f2"; # Foreground

          highlight-color = "#ffb86c"; # Orange
          highlight-active-color = "#ff79c6"; # Pink

          default-bg = "#282a36"; # Background
          default-fg = "#f8f8f2"; # Foreground

          render-loading = "true";
          render-loading-fg = "#282a36"; # Background
          render-loading-bg = "#f8f8f2"; # Foreground

          recolor = "true";
          adjust-open = "width";
          selection-clipboard = "clipboard";
        };
      };
    };

    # Theming of GTK applications
    gtk = {
      enable = true;

      gtk2.extraConfig = "gtk-application-prefer-dark-theme=1";
      gtk3.extraConfig = {
        "gtk-application-prefer-dark-theme" = 1;
      };
      gtk4.extraConfig = {
        "gtk-application-prefer-dark-theme" = 1;
      };

      theme = {
        name = "Qogir-Dark"; # These names can be found by running GDK_BACKEND=x11 lxappearance, capitalization matters
        # Corresponding pacakge is installed in configuration.nix
      };
      iconTheme = {
        name = "Qogir-dark"; # These names can be found by running GDK_BACKEND=x11 lxappearance, capitalization matters
        # Corresponding pacakge is installed in configuration.nix
      };
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  };
}
