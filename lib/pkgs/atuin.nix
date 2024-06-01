{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    atuin
  ];

  home-manager.users.atropos.programs.atuin = {
    enable = true;
    settings = {
      sync_address = "http://atuin";
      auto_sync = true;
      sync_frequency = "10s";
      search_mode = "fuzzy";
      daemon = {
        enabled = true;
      };
      key_path = config.sops.secrets."atuin/key".path;
    };
    flags = ["--disable-up-arrow"];
  };

  sops.secrets."atuin/key" = {
    owner = config.users.users.atropos.name;
  };

  # In preparation when atuin has a daemon mode
  # systemd.user.services.atuind = {
  #   description = "Atuin Daemon";
  #   after = ["network.target"];
  #   wantedBy = ["default.target"];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.writeShellScript "atuind" ''
  #       ${pkgs.atuin}/bin/atuin daemon
  #     ''}";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };
}
