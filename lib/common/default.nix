{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  nixpkgs = inputs.nixpkgs-unstable;
  attic_pkgs = inputs.attic.packages.${pkgs.system};

  homeUser = "atropos";
  homeDirectory = "/home/${homeUser}";
  rootHomeUser = "root";
  rootHomeDirectory = "/root";

  inherit (config.networking) hostName;
  shortHostName =
    if builtins.substring 0 4 hostName == "atro"
    then builtins.substring 4 (builtins.stringLength hostName) hostName
    else hostName;
  stateVersion = "25.05";
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence # Is used within some modules not necessarily used though.
    inputs.disko.nixosModules.disko # Is used within some modules not necessarily used though.
    ../pkgs/sopsnix.nix
    ../pkgs/fastfetch.nix
    ../pkgs/atuin.nix
    ../pkgs/eza.nix
    ../pkgs/git.nix
    ../pkgs/zsh
    ../pkgs/starship.nix
    ../pkgs/htop.nix
    ../pkgs/attic-client.nix
    ../pkgs/nvim.nix
    ../pkgs/tmux.nix
    ../pkgs/jq.nix
    ./nix.nix
    ./identities/users.nix
    ./identities/known_hosts.nix
    ./networking.nix
  ];

  # To avoid the "too many open files" error
  # This is equivalent to `ulimit -n 16192:1048576`
  # Or setting `DefaultLimitNOFILE=16192:1048576` in /etc/systemd/system.conf
  systemd.extraConfig = "DefaultLimitNOFILE=16192:1048576";

  topology.self = {
    interfaces = {
      tailscale0 = {
        network = "TAILSCALE";
        virtual = true;
        type = "wireguard";
      };
    };
  };

  # Basic system configuration
  system = {
    inherit stateVersion;

    # Provides diff to current system and what it was upgraded to.
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };
  };

  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd = {
    # WARN: Typically 100 score is default. 250 means nix rebuilding is more likely to be OOM killed than other stuff.
    services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  # Hardware configuration
  hardware = {
    enableRedistributableFirmware = true;
  };
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12;
    binfmt.emulatedSystems =
      if (pkgs.system == "x86_64-linux")
      then ["aarch64-linux"]
      else ["x86_64-linux"];
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.ip_forward" = 1; # Enable IP forwarding for tailscale
      "net.ipv6.conf.all.forwarding" = 1; # Enable IP forwarding for tailscale
      "net.core.rmem_max" = 7500000; # Necessary for syncthing
      "net.core.wmem_max" = 7500000; # Necessary for syncthing
      "fs.inotify.max_user_instances" = 8192;
    };
  };

  environment.sessionVariables = {
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "GOPATH" = "${homeDirectory}/.go";
  };

  # Docker support
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  environment = {
    etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
    variables.EDITOR = "nvim";
    systemPackages = with pkgs;
      [
        # Utilities like iostat, pidstat, sar etc.
        sysstat

        # Containerization
        dive
        docker
        docker-compose

        lnav
        viddy # watch replacement
        xcp
        ripgrep
        gnumake
        gcc
        clang

        pciutils # lspci

        # useful tldr
        tldr

        # file manager
        yazi

        # dns resolving tool (for testing)
        dig

        # Basic system utilities
        gnused
        util-linuxMinimal

        # Cached nix-shell calls.
        cached-nix-shell

        # devenv
        devenv

        # allows to kill apps
        killall

        # network bandwidth monitoring
        bandwhich

        # storage control
        duf
        ncdu

        # nfs utils (mounting etc.)
        nfs-utils

        # "cat" with syntax highlighting and other fancy stuff, slower than cat though
        bat

        # VPN mesh network
        tailscale

        # Resilient SSH alternative
        mosh

        # speed testing
        speedtest-cli

        # better find
        fd

        # fuzzy finder used by bunch of apps (e.g. telescope in nvim)
        fzf

        # Nice git diff
        delta

        # grep but faster
        ripgrep

        # Basic CLI downloader
        wget

        # checking temps and basics
        lm_sensors

        # Setting POSIX commands
        libcap

        # Internet interface testing
        iperf

        # bunch of network rules
        # iptables

        # controlling network interface
        ethtool

        # Allows fancy terminal directory jumping (with memory of where you have been)
        zoxide

        # json diff
        python312Packages.jsondiff

        # simple apps to show resources
        onefetch
        cpufetch
        ramfetch

        # zip and unzip
        unzip
        p7zip
      ]
      ++ [attic_pkgs.attic];
  };

  services = {
    # vpn mesh to connect to other devices
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale/key".path;
      package = pkgs.tailscale;
      extraUpFlags = [
        "--hostname=${shortHostName}"
      ];
    };

    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = lib.mkForce "prohibit-password"; # disable root login with password
        PasswordAuthentication = false; # disable password login
      };
      openFirewall = true;
    };
  };

  security = {
    doas.enable = true; # Sudo related
    sudo = {
      enable = true;
      extraConfig = ''
        Defaults  lecture="never"
      '';
      extraRules = [
        {
          # special sudo rules, what is typically in visudo
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl suspend";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.systemd}/bin/reboot";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.systemd}/bin/poweroff";
              options = ["NOPASSWD"];
            }
          ];
          groups = ["wheel"];
        }
      ];
    };
  };

  home-manager.users.root = {
    home = {
      # Base home manager configuration
      username = rootHomeUser;
      homeDirectory = rootHomeDirectory;
      inherit stateVersion;
    };
  };
  home-manager.users.atropos = {
    home = {
      # Base home manager configuration
      username = homeUser;
      inherit homeDirectory stateVersion;

      sessionPath = [
        "$HOME/.bun/bin"
        "$HOME/.go/bin"
        "$HOME/.cargo/bin"
        "$HOME/bins"
      ];
    };
  };
}
