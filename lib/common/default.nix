{
  self,
  pkgs,
  inputs,
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
in {
  imports = [
    ../pkgs/sopsnix.nix
    # ../pkgs/atuin.nix # WARN: Atuin is not working well, sqlite is timing out some ZFS-sqlite issue. Once daemon works this can be enabled.
    ../pkgs/git.nix
    ../pkgs/zsh
    ../pkgs/htop.nix
    ../pkgs/attic-client.nix
    ../pkgs/nvim.nix
    ../pkgs/tmux.nix
    ./nix.nix
    ./identities/users.nix
    ./identities/known_hosts.nix
  ];

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
    stateVersion = "unstable";
    configurationRevision =
      if (self ? rev)
      then self.rev
      else null; #throw "refuse to build: git tree is dirty";

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
    binfmt.emulatedSystems =
      if (pkgs.system == "x86_64-linux")
      then ["aarch64-linux"]
      else ["x86_64-linux"];
    kernel.sysctl = {
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
        # Cached nix-shell calls.
        cached-nix-shell

        # devenv
        devenv

        # allows to kill apps
        killall

        # pretty ls
        eza

        # network bandwith monitoring
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

        # Allows conterinization of applications and whole OS's
        docker

        # Allows yaml defined docker container for easier reproducability and editability
        docker-compose

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

        # Useful for CLI based json processing
        jq

        # checking temps and basics
        lm_sensors

        # Setting POSIX commands
        libcap

        # Internet interface testing
        iperf

        # bunch of network rules
        iptables

        # controling network interface
        ethtool

        # Allows fancy terminal directory jumping (with memory of where you have been)
        zoxide

        # json diff
        python312Packages.jsondiff

        # simple apps to show resources
        fastfetch
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
      extraUpFlags = [
        "--hostname=${shortHostName}"
      ];
    };

    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "prohibit-password"; # disable root login with password
        PasswordAuthentication = false; # disable password login
      };
      openFirewall = true;
    };
  };

  programs = {
    # Version control application.
    git.enable = true;
  };

  security = {
    doas.enable = true; # Sudo related
    sudo = {
      enable = true;
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
      stateVersion = "24.05";
    };
  };
  home-manager.users.atropos = {
    home = {
      # Base home manager configuration
      username = homeUser;
      inherit homeDirectory;
      stateVersion = "24.05";

      sessionPath = [
        "$HOME/.bun/bin"
        "$HOME/.go/bin"
        "$HOME/.cargo/bin"
        "$HOME/bins"
      ];
    };

    programs = {
      # Execute scripts on directory entry, convenient for setups etc.
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        package = pkgs.direnv;
      };
    };
  };
}
