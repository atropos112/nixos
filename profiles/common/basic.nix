{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  nixpkgs = inputs.nixpkgs-unstable;

  homeUser = "atropos";
  homeDirectory = "/home/${homeUser}";
  rootHomeUser = "root";
  rootHomeDirectory = "/root";
  stateVersion = "25.05";
in {
  imports = [
    # Profiles
    ../zsh
    ../nix.nix
    ../identities/users.nix
    ../identities/known_hosts.nix
    ../networking
    ../fastfetch.nix
    ../services/atuin.nix
    ../services/atticClient
    ../../profiles/alloy

    # Packages
    ../../pkgs/git.nix
    ../../pkgs/starship.nix
    ../../pkgs/htop.nix
    ../../pkgs/nvim.nix
    ../../pkgs/tmux.nix
    ../../pkgs/nixIndex.nix
  ];

  # Secrets that don't fit in other modules/pkgs
  sops.secrets = {
    "wakatime/cfg" = {
      owner = config.users.users.atropos.name;
      mode = "0444";
      path = "/home/${config.users.users.atropos.name}/.config/wakatime/.wakatime.cfg";
    };
    "tailscale/key" = {};
  };

  virtualisation.oci-containers.backend = "podman";

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

  systemd = {
    # WARN: Typically 100 score is default. 250 means nix rebuilding is more likely to be OOM killed than other stuff.
    services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;

    # To avoid the "too many open files" error
    # This is equivalent to `ulimit -n 16192:1048576`
    # Or setting `DefaultLimitNOFILE=16192:1048576` in /etc/systemd/system.conf
    settings.Manager = {
      DefaultLimitNOFILE = "16192:1048576";
    };
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  # Hardware configuration
  hardware = {
    enableRedistributableFirmware = true;
  };
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_6_17;
    binfmt.emulatedSystems =
      if (pkgs.stdenv.hostPlatform.system == "x86_64-linux")
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

  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true; # alias docker -> podman
    };
  };

  atro.fastfetch.modules = [
    {
      priority = 1000;
      value = {
        "type" = "command";
        "text" = "systemctl is-active podman";
        "key" = "Podman";
      };
    }
  ];

  environment = {
    etc."nix/inputs/nixpkgs".source = "${nixpkgs}";

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      GOPATH = "${homeDirectory}/.go";

      FZF_BASE = "${pkgs.fzf}/bin/fzf";

      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      DEVENV_TASKS_QUIET = "true"; # No "Running tasks     devenv:enterShell" outputs
    };

    systemPackages = with pkgs;
      [
        # Tui for systemctl
        systemctl-tui

        # For IO monitoring
        iotop

        # Data processors for json, yaml, xml etc.
        jq
        yq
        xq

        docker-client

        # Utilities like iostat, pidstat, sar etc.
        sysstat

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
        eza
      ]
      ++ [
        inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };

  # This is a workaround since we restart igc module on resume
  systemd.services.chronyd = {
    serviceConfig.ExecStartPre = [
      # Using pool europe.pool.ntp.org to have multiple servers to sync from
      # Just in case one is down (which has happened in the past)
      "${pkgs.chrony}/bin/chronyd -q 'pool europe.pool.ntp.org iburst'"
      "${pkgs.coreutils}/bin/sleep 5"
    ]; # for good measure
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  services = {
    # NTP (time syncing) service
    # systemd-timesyncd is used by default unless something else is set (e.g. chrony)
    # and chrony is considered more reliable.
    chrony.enable = true;

    # vpn mesh to connect to other devices
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale/key".path;
      package = pkgs.tailscale;
      extraUpFlags = [
        "--hostname=${config.networking.hostName}"
        "--accept-dns=false" # This is done manually in the networking/dns.nix
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
