{
  inputs,
  pkgs,
  pkgs-stable,
  lib,
  ...
}: let
  homeUser = "atropos";
  homeDirectory = "/home/${homeUser}";
in {
  imports = [
    ../default.nix
    inputs.stylix.nixosModules.stylix
    inputs.nix-index-database.nixosModules.nix-index
    ../../modules/exmounts.nix
    ../kubernetes/user.nix
    # ../../pkgs/kitty.nix
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
    ../../pkgs/python.nix
    ../../pkgs/go.nix
    ../../pkgs/zig.nix
    ../../pkgs/csharp.nix
    ../../pkgs/firefox.nix
    ../../pkgs/direnv.nix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/images8/Free-Download-Space-Backgrounds-HD-for-Desktop.jpg";
      sha256 = "sha256-2o27/58lJugkUVN4SWm7PXWA9J+9bbaU3HQLAq9Qsd0=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    cursor.size = 24;
    opacity = {
      terminal = 0.95;
    };
  };

  # Linking fonts. This is a hack to get around the fact that the fonts are in a different place than the system expects.
  # system.activationScripts.usrlocalbin = ''
  #   mkdir -m 0755 -p /usr/local
  #   ln -nsf /home/atropos/media/fonts /home/atropos/.local/share/fonts
  # '';

  atro.extMounts = {
    enable = true;
  };

  atro.kopia = {
    enable = true;
    runAs = "root";
  };

  # Enabled by default, but is needed if you are a purist so putting it here to make it explicit.
  nix.settings.sandbox = true;
  # Networking basics (hostname excluded)
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };

  virtualisation.docker = {
    storageDriver = "zfs";
  };

  hardware = {
    # OpenGL acceleration etc.
    graphics.enable = true;

    # Bluetooth support
    bluetooth.enable = true;
  };

  environment.sessionVariables = {
    # To Globally replace gcc stuff use this env var but it will do damage to othre stuff so ideally use nix-ld approach
    # LD_LIBRARY_PATH = lib.mkForce "${pkgs.stdenv.cc.cc.lib}/lib";
    FZF_BASE = "${pkgs.fzf}/bin/fzf";

    # hint XDG to use wayland
    XDG_SESSION_TYPE = "wayland";

    # hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";

    # Inform all GDK apps its wayland env
    GDK_BACKEND = lib.mkDefault "wayland, x11";

    # Inform QT apps of the version
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Base
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Hyprland scaling
    GDK_SCALE = "1";
  };

  security = {
    rtkit.enable = true; # Recommended for pipewire
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

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

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
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
    displayManager = {
      autoLogin = {
        enable = false; # I want to type my password as I may come remotely.
        user = "atropos";
      };
    };

    # For XDG portals to work
    dbus.enable = true;
  };

  programs = {
    # nix-locate "bin/firefox" will show where the firefox binary is located
    nix-index = {
      enableZshIntegration = false;
      enableBashIntegration = false;
    };
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
  };

  # Allowing for "sshfs rzr:/mnt/media /mnt/media -o allow_other" so that docker can use the mount as well not just the user.
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs;
    [
      # inspection tool for current system state
      nix-inspect

      # LSP for nix
      nixd

      # To mount remote directories
      sshfs
      # Music player
      feishin

      vscode-langservers-extracted

      # Project template generator
      copier

      # Basic gpg encryption stuff
      gnupg

      # So that i can call xrandr to instruct xwayland which screen is primary
      wlr-randr

      # File manager
      gnome.nautilus

      # Backup solution
      kopia

      # Interacts with the service to provide power usage information, e.g. how much battery is left.
      upower

      # To set/get screen brightness
      brightnessctl

      # Provide a "shutdown" window for GUI convenience
      wlogout

      # Provides controls for sound related matters
      pavucontrol

      # Zig
      zig

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

      # Rust debug server
      vscode-extensions.vadimcn.vscode-lldb.adapter

      # Multiplexer for terminal
      tmux

      # pdf viewer
      zathura

      # connect to k8s external secret source
      doppler

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
      dbeaver-bin

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
      iamb # terminal client for matrix
    ]
    ++ (with pkgs-stable; [
      # Vivaldi is a web browser
      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = false;
        inherit vivaldi-ffmpeg-codecs;
        commandLineArgs = [
          "--ozone-platform-hint=auto" # autodetect wayland or x11
        ];
      })
      vivaldi-ffmpeg-codecs
      widevine-cdm
    ]);

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
          source = config.lib.file.mkOutOfStoreSymlink "/home/atropos/Sync/fonts";
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
          "indicator" = true;
          "indicator-radius" = "200";
          "indicator-thickness" = "20";
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
        name = lib.mkForce "Qogir-Dark"; # These names can be found by running GDK_BACKEND=x11 lxappearance, capitalization matters
        # Corresponding package is installed in configuration.nix
      };
      iconTheme = {
        name = lib.mkForce "Qogir-dark"; # These names can be found by running GDK_BACKEND=x11 lxappearance, capitalization matters
        # Corresponding package is installed in configuration.nix
      };
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkForce "prefer-dark";
        };
      };
    };
  };
}
