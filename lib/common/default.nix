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
    inputs.nix-colors.homeManagerModules.default
    ../pkgs/atuin.nix
    ../pkgs/git.nix
    ../pkgs/zsh
    ../pkgs/htop.nix
    ../pkgs/attic-client.nix
    ./authorized-keys.nix
  ];
  colorScheme = inputs.nix-colors.colorSchemes.onedark;

  # Basic system configuration
  system = {
    stateVersion = "unstable";
    configurationRevision =
      if (self ? rev)
      then self.rev
      else null; #throw "refuse to build: git tree is dirty";
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking basics (hostname excluded)
  networking = {
    usePredictableInterfaceNames = false;
    nftables.enable = false; # prefer iptables still
    firewall.enable = false;
    enableIPv6 = true;
  };

  # Basic Nix configuration
  nix = {
    settings = {
      auto-optimise-store = true;
      substituters = [
        "http://rzr:8099/atro" # My attic server
        "https://hyprland.cachix.org" # Hyprland Cachix server
      ];

      trusted-public-keys = [
        "atro:HEm1RhnPVzZI/fxjJaqVZDunIRVYlSrm01NvnQMpwiw=" # My attic server
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Hyprland Cachix server
      ];

      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
    registry.nixpkgs.flake = nixpkgs;
    nixPath = ["/etc/nix/inputs"];
  };

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
    # Modern VIM
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

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

  users = {
    groups = {
      plugdev = {};
    };

    groups.atropos = {};

    users = {
      root = {
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgtcKNMhw2C8xpbIVaOPfLBr9f93JXxLgp2LVr7CPlJ root@giant"
        ];
      };
      atropos = {
        isNormalUser = true;
        useDefaultShell = true;
        home = "/home/atropos";
        group = "atropos";
        createHome = true;
        extraGroups = ["wheel" "audio" "networkmanager" "docker" "input" "plugdev"];
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGqRdI3cwDuF/x1Hdr2AGmnNjTiU7hfXePqzlEMVn7F AtroGiant"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzyzsV64asxyikHArB1HNNMg2R9YGoepmpBnGzZjkE atropos@AtroSurface"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLyjGaUMq7SWWUXdew/+E213/KCUDB1D59iEOhE6gyB atropos@giant"
        ];
      };
    };
  };

  home-manager.users.root = {
    #colorScheme = inputs.nix-colors.colorSchemes.onedark;
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
      # Execute scripts on directory entry, convinient for setups etc.
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        package = pkgs.direnv;
      };

      tmux = {
        enable = true;
        package = pkgs.tmux;
        plugins = with pkgs.tmuxPlugins; [
          onedark-theme
          cpu
          yank
          tmux-fzf
          net-speed
          prefix-highlight
          open
          copycat
        ];
        # extraConfig = ''
        #   set -g @open 'C-o'
        #   set-option -g default-shell /usr/bin/env zsh
        #   set -g @open-editor 'o'
        #   set -g @onedark_widgets "#{prefix_highlight} CPU: #{cpu_percentage} | NET: #{net_speed}"
        #   set -g mouse on
        # '';
      };
    };
  };
}
