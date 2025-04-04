{
  config,
  pkgs,
  ...
}: let
  at_bin = "${pkgs.atuin}/bin/atuin";
in {
  environment.systemPackages = with pkgs; [
    atuin
  ];

  home-manager.users.atropos.programs.atuin = {
    enable = true;
    package = pkgs.atuin;
    enableZshIntegration = true;
    # home manager daemon is meh.
    # daemon = {
    #   enable = true;
    #   logLevel = "info";
    # };
    settings = {
      sync_address = "http://atuin";
      auto_sync = true;
      sync_frequency = "10s";
      search_mode = "fuzzy";
      daemon = {
        enabled = true;
        sync_frequency = "10"; # 10 seconds sync
        systemd_socket = true; # set by deamon.enable anyway.
      };
      key_path = config.sops.secrets."atuin/key".path;
    };
    flags = ["--disable-up-arrow"];
  };

  sops.secrets = {
    "atuin/key" = {
      owner = config.users.users.atropos.name;
    };
    "atuin/mnemonic" = {
      owner = config.users.users.atropos.name;
    };
    "atuin/username" = {
      owner = config.users.users.atropos.name;
    };
    "atuin/password" = {
      owner = config.users.users.atropos.name;
    };
  };

  systemd.user = {
    sockets = {
      atuind = {
        description = "Atuin Daemon Socket";
        partOf = ["atuind.service"];
        wantedBy = ["sockets.target"];
        socketConfig = {
          ListenStream = "%t/atuin.sock";
          SocketMode = "0600";
          RemoveOnStop = true;
        };
      };
    };

    services = {
      # Separated into two services to allow socket to work. Not sure if this is necessary.

      atuind = {
        description = "Atuin Credential Setup";
        wantedBy = ["multi-user.target"];
        requires = ["atuind-creds.service" "atuind.socket"];
        after = ["network.target"];
        partOf = ["atuind-creds.service"];
        serviceConfig = {
          ExecStart = "${pkgs.atuin}/bin/atuin daemon";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      atuind-creds = {
        description = "Atuin Credential Setup";
        wantedBy = ["multi-user.target"];
        partOf = ["atuind-creds.service"];
        before = ["atuind.service"];
        after = ["network.target"];
        serviceConfig = {
          ExecStart = "${pkgs.writeShellScript "atuin-credentials" ''
            USERNAME=$(cat ${config.sops.secrets."atuin/username".path})
            PASSWORD=$(cat ${config.sops.secrets."atuin/password".path})
            MNEMONIC=$(cat ${config.sops.secrets."atuin/mnemonic".path})

            ${at_bin} logout
            ${at_bin} login -k "$MNEMONIC" -u "$USERNAME" -p "$PASSWORD"
            ${at_bin} status # For logging purposes
          ''}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
  };
}
