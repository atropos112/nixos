{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    atuin
  ];

  home-manager.users.atropos.programs.atuin = {
    enable = true;
    package = pkgs.atuin;
    enableZshIntegration = true;
    # WARN: You might think "I can override the ExecStart line in the service" the level of pain it caused me
    # to try this, its honstly not worth it, decided to create my own service, socket and service for creds instead.
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

  atro.fastfetch.modules = [
    {
      priority = 1003;
      value = {
        "type" = "command";
        "text" = "systemctl is-active --user atuin-syncer";
        "key" = "Atuin";
      };
    }
  ];

  systemd.user = {
    sockets = {
      atuin-syncer = {
        description = "Atuin Daemon Socket";
        partOf = ["atuin-syncer.service"];
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

      atuin-syncer = {
        description = "Atuin Sync Setup";
        wantedBy = ["multi-user.target"];
        requires = ["atuin-auth.service" "atuin-syncer.socket"];
        after = ["network.target"];
        serviceConfig = {
          # WARN: This really does need to be one liner app-starter and not a shell script.
          # Otherwise it won't connect to the socket
          ExecStart = "${lib.getExe pkgs.atuin} daemon";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      atuin-auth = {
        description = "Atuin Credential Setup";
        wantedBy = ["multi-user.target"];
        before = ["atuin-syncer.service"];
        after = ["network.target"];
        serviceConfig = {
          ExecStart = "${pkgs.writeShellScript "atuin-auth" ''
            USERNAME=$(cat ${config.sops.secrets."atuin/username".path})
            PASSWORD=$(cat ${config.sops.secrets."atuin/password".path})
            MNEMONIC=$(cat ${config.sops.secrets."atuin/mnemonic".path})

            ${lib.getExe pkgs.atuin} logout
            ${lib.getExe pkgs.atuin} login -k "$MNEMONIC" -u "$USERNAME" -p "$PASSWORD"
            ${lib.getExe pkgs.atuin} status
          ''}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
  };
}
