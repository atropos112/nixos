{
  inputs,
  config,
  pkgs,
  ...
}: let
  atuin_pkgs = inputs.atuin.packages.${pkgs.system};
in {
  environment.systemPackages = with atuin_pkgs; [
    atuin
  ];

  home-manager.users.atropos.programs.atuin = {
    enable = true;
    package = atuin_pkgs.atuin;
    settings = {
      sync_address = "http://atuin";
      auto_sync = true;
      sync_frequency = "10s";
      search_mode = "fuzzy";
      daemon = {
        enabled = true;
        socket_path = "/home/atropos/.config/atuin/socket";
        sync_frequency = "10"; # 10 seconds sync
      };
      key_path = config.sops.secrets."atuin/key".path;
    };
    flags = ["--disable-up-arrow"];
  };

  sops.secrets."atuin/key" = {
    owner = config.users.users.atropos.name;
  };

  systemd.user.services.atuin-daemon = {
    description = "Atuin Daemon";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "atuin-daemon" ''
        ${atuin_pkgs.atuin}/bin/atuin daemon
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
