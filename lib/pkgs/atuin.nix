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
      sync_address = "http://atuin:8888";
      auto_sync = true;
      sync_frequency = "10s";
      search_mode = "fuzzy";
      key_path = config.sops.secrets."atuin/key".path;
    };
    flags = ["--disable-up-arrow"];
  };

  sops.secrets."atuin/key" = {
    owner = config.users.users.atropos.name;
  };
}
