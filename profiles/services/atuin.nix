{
  config,
  pkgs,
  lib,
  ...
}: {
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
      search_mode = "fuzzy";
      daemon = {
        enabled = true;
        sync_frequency = 300; # 5 minutes
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
        # not using systemctl is-active --user atuin-syncer
        # because it doesn't work on SSH (turns alive momentarily after login)
        "text" = "pgrep -f 'atuin daemon' > /dev/null && echo 'active' || echo 'inactive'";
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
        wantedBy = ["default.target"];
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
        wantedBy = ["default.target"];
        before = ["atuin-syncer.service"];
        after = ["network-online.target"];
        wants = ["network-online.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.writeShellScript "atuin-auth" ''
            # Skip if already logged in
            if ${lib.getExe pkgs.atuin} status | grep -q "Username:"; then
              echo "Already logged in, skipping auth"
              exit 0
            fi

            USERNAME=$(cat ${config.sops.secrets."atuin/username".path})
            PASSWORD=$(cat ${config.sops.secrets."atuin/password".path})
            MNEMONIC=$(cat ${config.sops.secrets."atuin/mnemonic".path})

            ${lib.getExe pkgs.atuin} login -k "$MNEMONIC" -u "$USERNAME" -p "$PASSWORD"
            ${lib.getExe pkgs.atuin} status
          ''}";
          Restart = "on-failure";
          RestartSec = "30s";
          # Prevent rapid restart loops - allow 3 restarts in 5 minutes
          StartLimitIntervalSec = 300;
          StartLimitBurst = 3;
        };
      };
    };
  };
}
