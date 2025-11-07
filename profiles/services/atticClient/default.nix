{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    attic-client
  ];

  sops.secrets."attic/netrc" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
  };
  sops.secrets."attic/config" = {
    owner = "root";
    path = "/root/.config/attic/config.toml";
    mode = "0444"; # Read only
  };

  atro.fastfetch.modules = [
    {
      priority = 1002;
      value = {
        "type" = "command";
        "text" = "systemctl is-active attic-client";
        "key" = "Attic";
      };
    }
  ];

  nix.settings.netrc-file = config.sops.secrets."attic/netrc".path;
  systemd.services.attic-client = {
    description = "Attic watch store";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.attic-client}/bin/attic watch-store atticd:atro --ignore-upstream-cache-filter";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
