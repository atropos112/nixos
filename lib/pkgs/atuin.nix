{
  inputs,
  config,
  pkgs,
  ...
}: let
  atuin_pkgs = inputs.atuin.packages.${pkgs.system};
  at_bin = "${atuin_pkgs.atuin}/bin/atuin";
  socket_path = "/home/atropos/.config/atuin/socket";
in {
  environment.systemPackages = with atuin_pkgs; [
    atuin
  ];

  home-manager.users.atropos.programs.atuin = {
    enable = true;
    package = atuin_pkgs.atuin;
    enableZshIntegration = true;
    settings = {
      sync_address = "http://9.0.0.91";
      auto_sync = true;
      sync_frequency = "10s";
      search_mode = "fuzzy";
      daemon = {
        enabled = true;
        inherit socket_path;
        sync_frequency = "10"; # 10 seconds sync
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

  systemd.user.services.atuin-daemon = {
    description = "Atuin Daemon";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "atuin-daemon" ''
        USERNAME=$(cat ${config.sops.secrets."atuin/username".path})
        PASSWORD=$(cat ${config.sops.secrets."atuin/password".path})
        MNEMONIC=$(cat ${config.sops.secrets."atuin/mnemonic".path})

        ${at_bin} logout
        ${pkgs.coreutils}/bin/rm -rf "${socket_path}"
        ${at_bin} login -k "$MNEMONIC" -u "$USERNAME" -p "$PASSWORD"
        ${at_bin} status # For logging purposes
        ${at_bin} daemon
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
