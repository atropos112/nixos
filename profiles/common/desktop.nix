{
  inputs,
  pkgs,
  pkgs-stable,
  pkgs-master,
  lib,
  ...
}: let
  homeUser = "atropos";
  homeDirectory = "/home/${homeUser}";
  theme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

  accent = "blue";
  variant = "macchiato";
  kvantumThemePackage = pkgs.catppuccin-kvantum.override {
    inherit variant accent;
  };
in {
  imports = [
    ./basic.nix
    inputs.stylix.nixosModules.stylix
    inputs.nix-ld.nixosModules.nix-ld
    # Profiles
    ../externalMounts/all.nix
    ../kopia/to_rzr.nix
    ../hyprland.nix
    ../kubernetes/user.nix
    ../languages/all.nix
    ../zfs
    ../identities/infisical.nix

    # Packages
    ../../pkgs/kitty.nix
    ../../pkgs/waybar
    ../../pkgs/mako.nix
    ../../pkgs/tofi.nix
    ../../pkgs/firefox.nix
    ../../pkgs/direnv.nix
    ../../pkgs/nixSearchTV.nix
    ../../pkgs/mods.nix
    ../../pkgs/clipse.nix
  ];

  stylix = {
    cursor = {
      size = 24;
      name = "Capitaine Cursors - White";
      package = pkgs.capitaine-cursors-themed;
    };

    enable = true;
    autoEnable = true;
    polarity = "dark";
    image = ./wallpaper.png;
    base16Scheme = theme;
    opacity = {
      terminal = 0.95;
    };
  };

  # Linking fonts. This is a hack to get around the fact that the fonts are in a different place than the system expects.
  # system.activationScripts.usrlocalbin = ''
  #   mkdir -m 0755 -p /usr/local
  #   ln -nsf /home/atropos/media/fonts /home/atropos/.local/share/fonts
  # '';

  atro = {
    externalMounts = {
      enable = true;
    };

    kopia = {
      runAs = "root";
      backups = [
        {
          path = "/persistent/";
          ignores = ["Sync" ".venv" ".cache" ".devenv" ".devenv*"];
        }
      ];
    };
  };

  # INFO: Lowering the priority of nix daemon processes so that they do not interfere with normal system usage.
  # This is especially useful for desktops where user interactivity is important.
  # It is also where we expect to have some low IO and low CPU usage times because typically desktop usage is intermittent unlike servers.
  # Got this idea from https://www.reddit.com/r/NixOS/comments/1ompdwi/comment/nmqzk3i/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  nix = {
    daemonCPUSchedPolicy = "idle"; # CPU config
    daemonIOSchedClass = "idle"; # IO config
  };

  # Enabled by default, but is needed if you are a purist so putting it here to make it explicit.
  nix.settings.sandbox = true;
  # Networking basics (hostname excluded)
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };

  virtualisation = {
    docker = {
      storageDriver = "zfs";
    };
  };

  hardware = {
    # OpenGL acceleration etc.
    graphics.enable = true;

    # Bluetooth support
    bluetooth.enable = true;
  };

  environment.sessionVariables = {
    # I strongly prefer free open-source software.
    # I do also think os shouldn't try to suggest me going one way or another. You convince people
    # by showing them the community, the support, the quality of software not by having them jump
    # through hoops to bypass your ideologies.
    # For OS to try to make it even an inch harder to use unfree software is I think a stupid design
    # and I will disable it everywhere I can, I will make my decision myself and OS shouldn't try to
    # encourage me through inconvenience of setting a flag/config to use or not to use unfree software.
    # Its this idea of "we know better than you" the shitheads at Apple and Google do that I despise,
    # and someone at NixOS thought it was a good idea to do the same.
    NIXPKGS_ALLOW_UNFREE = "1";

    # To match the cursor theme with the rest of the system
    XCURSOR_THEME = "Capitaine Cursors - White";
    XCURSOR_SIZE = "24";

    # To Globally replace gcc stuff use this env var but it will do damage to other stuff so ideally use nix-ld approach
    # LD_LIBRARY_PATH = lib.mkForce "${pkgs.stdenv.cc.cc.lib}/lib";
    # hint XDG to use wayland
    XDG_SESSION_TYPE = "wayland";

    # hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";

    WAKATIME_HOME = "${homeDirectory}/.config/wakatime";

    # Inform all GDK apps its wayland env
    GDK_BACKEND = lib.mkDefault "wayland, x11";

    QT_STYLE_OVERRIDE = "kvantum";

    QT_QPA_PLATFORM = "wayland";

    VISUAL = "nvim";

    # Hyprland scaling
    GDK_SCALE = "1";

    # Bunch of libraries need to know this so location, like nvim's sqlite3 plugin
    ATRO_SQLITE3_SO_PATH = "${pkgs.sqlite.out}/lib/libsqlite3.so";

    KREW_ROOT = "/persistent/home/atropos/.krew";

    NATS_URL = "nats://nats:4222";
  };

  security = {
    rtkit.enable = true; # Recommended for pipewire
    pam.services = {
      gdm.enableGnomeKeyring = true; # To make the keyring work, for things like github copilot
      swaylock = {}; # To make swaylock respect my password or fprintd if exists
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
    pipewire = lib.mkDefault {
      enable = true;
      wireplumber.enable = true; # This is the default, wanted to make it explicit.
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    # Bluetooth manager
    blueman.enable = true;

    # For security purposes some apps (e.g. github copilot) require keyring.
    gnome.gnome-keyring.enable = true;

    # IX Server does a lot, used for keyboard settings here and to select the display manager (Login screen)
    # Note, the keyboard settings are for stuff it controls like GDM, onced logged in, DE (e.g. HyprLand) takes over and that can dictate the keyboard.
    xserver = {
      enable = true;
    };
    # Display manager (Login screen)
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      autoLogin = {
        enable = false; # I want to type my password as I may come remotely.
        user = "atropos";
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

    nix-ld.dev.enable = true;

    # nix-ld = {
    #   enable = true;
    #   libraries = with pkgs; [
    #     zlib # numpy
    #     libgcc # sqlalchemy
    #   ];
    # };
  };

  # Allowing for "sshfs rzr:/mnt/media /mnt/media -o allow_other" so that docker can use the mount as well not just the user.
  programs.fuse.userAllowOther = true;

  environment.systemPackages =
    (with pkgs; [
      clipse
      libreoffice
      tree-sitter
      buildah

      # For shell script checking
      shellharden

      # VPN client
      protonvpn-gui

      cachix

      # Android mounting tool
      # Can run with:
      # mkdir temp
      # go-mtpfs -android temp
      # Once done, Ctrl + C and umount temp
      go-mtpfs

      # Clipboard manager
      cliphist

      # For spaced repetition memorisation
      anki

      # Search for nix packages
      nix-search-cli

      natscli

      # Net sniffer
      sniffnet

      signal-desktop
      zapzap

      sqlite

      httpie
      libsForQt5.qtstyleplugin-kvantum # themes for qt apps
      (catppuccin-kvantum.override {
        inherit accent variant;
      })
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct

      # For developing
      protobuf

      # For viewing json files
      jless

      # LSP for nix
      nixd

      # To mount remote directories
      sshfs

      vscode-langservers-extracted

      # Project template generator
      copier

      # Basic gpg encryption stuff
      gnupg

      # So that i can call xrandr to instruct xwayland which screen is primary
      wlr-randr

      # File manager
      nautilus

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
      kdePackages.polkit-kde-agent-1

      # Application killer
      killall

      # Keyring needed for some applications (e.g. github copilot)
      libgnome-keyring

      # Javascript runtimes
      bun
      nodejs_24

      # Get CPU temps etc.
      lm_sensors

      # perf testing of a bash call or multiple functions
      hyperfine

      # Qogir theme
      qogir-theme
      qogir-icon-theme

      # GTK theme gui manager
      lxappearance # To run it use: GDK_BACKEND=x11 lxappearance

      # Matrix client
      element-desktop

      # For better bluetooth controls
      bluez

      # Bluetooth tui
      bluetui

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

      # Curl with browser like interfaces
      # WARN: Not working currently
      # curl-impersonate

      # Using pamixer (alt paactl) and brightlessctl (alt light) it also creates nice graphic demonstrating levels
      avizo

      # Torrent client
      transmission_4-gtk

      # Font viewer (have to open twice for some reason)
      gnome-font-viewer

      # Multiplexer for terminal
      tmux

      # pdf viewer
      zathura

      # tool for partitioning
      parted

      # execution tool (in repos)
      gnumake

      # hacky tool to simulate keyboard inputs
      wtype

      # C++ compiler
      gcc

      #WIP
      hadolint
      czkawka
      gum
      ocaml
      wpaperd
      prek
      argocd
      statix # to give suggestions on nix stuff
      deadnix # look for dead nix code
      alejandra
      usbimager # etcher equiv
      nvd # diff for nixos deploys
      iamb # terminal client for matrix
      lima
    ])
    ++ [
      inputs.nil_ls.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nil
      inputs.colmena.outputs.packages.${pkgs.stdenv.hostPlatform.system}.colmena
      pkgs-stable.texliveFull # Because pkgs texliveFull is broken.
    ]
    ++ (with pkgs-master; [
      # Youtube (and more) downloader
      yt-dlp
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

  xdg = {
    # Portals are a standardised framework allowing desktop applications to use resources outside of their sandbox.
    portal = {
      enable = true;
    };
    mime = {
      enable = true;
    };
  };

  qt = {
    enable = true;
    style = lib.mkForce "kvantum";
  };

  home-manager.users.root = _: {
    stylix.enable = false;
  };

  home-manager.users.atropos = {config, ...}: {
    stylix.targets = {
      # TODO: Remove once https://github.com/danth/stylix/issues/630 is closed.
      hyprland.enable = false;

      # TODO: Remove once wpaperd is fixed to services.wpaperd.settings (as opposed to programs.wpaperd.settings)
      wpaperd.enable = false;

      # TODO: Remove once vscode is fixed to programs.vscode.default.profiles....
      vscode.enable = false;
    };
    home = {
      file = {
        ".local/share/fonts" = {
          enable = true;
          recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "/home/atropos/Sync/manual/fonts";
        };
        ".config/ZapZap/ZapZap.conf".text = ''
          [main]
          geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\x1\xe\0\0\x4\xf9\0\0\x6\x85\0\0\0\0\0\0\x1\xe\0\0\x4\xf9\0\0\x6\x85\0\0\0\x2\x2\0\0\0\n\0\0\0\0\0\0\0\x1\xe\0\0\x4\xf9\0\0\x6\x85)
          windowState=@ByteArray(\0\0\0\xff\0\0\0\0\xfd\0\0\0\0\0\0\x4\xfa\0\0\x5x\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\0)
          [performance]
          cache_size_max=100
          [system]
          menubar=false
          sidebar=false
          start_background=true
          theme=dark
          tray_theme=symbolic_light
          wayland=true
          [web]
          scroll_animator=true
          [website]
          open_page=false
        '';
      };

      sessionPath = [
        "/persistent/home/atropos/.krew/bin"
        "$HOME/.bun/bin"
        "$HOME/media/bins"
        "$HOME/.go/bin"
        "$HOME/Sync/bins"
      ];
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Catppuccin-${variant}-${accent}
      '';

      # The important bit is here, links the theme directory from the package to a directory under `~/.config`
      # where Kvantum should find it.
      "Kvantum/Catppuccin-${variant}-${accent}".source = "${kvantumThemePackage}/share/Kvantum/Catppuccin-${variant}-${accent}";
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
            timeout = 5280; # 90min - 2 minutes
            command = "${pkgs.libnotify}/bin/notify-send -u 'low' 'Suspending and locking in 2 minutes...'";
          }
          {
            timeout = 5390; # 90min - 10seconds
            command = "${pkgs.libnotify}/bin/notify-send -u 'critical' 'Suspending and locking in 10 seconds...'";
          }
          {
            timeout = 5400; # 90min
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
    services = {
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
    };

    programs = {
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
          "ignore-empty-password" = false;
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
