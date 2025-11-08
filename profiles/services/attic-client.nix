{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    attic-client
  ];

  # INFO: To get this token I ran
  # atticadm make-token \
  # --validity "10y" \
  # --sub "atro" \
  # --pull "atro" \
  # --push "atro" \
  # --priority 1 \
  # --create-cache "atro" \
  # --configure-cache "atro" \
  # --configure-cache-retention "atro" \
  # --destroy-cache "atro*" -f ./temp.toml
  # Where temp.toml is the file matching config.toml on the server.
  # You might think you can do "*" instead of "atro" but that will not work.
  # WARN: When starting a new cache on an attic server you must do
  # attic login atticd http://atticd. <token from above here>
  # attic cache create atro
  # attic cache use atro
  # attic cache configure atro --priority 1 (can also be overrideng by setting ?priortiy=N on the substituer by using http://atticd./atro?priority=1 for example), in fact i did both just to be sure.
  # After this you can find netrc file in ~/.config/nix/netrc and place it in sops.
  sops.secrets."attic/netrc" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
  };
  # INFO: Once I had the token from above I did
  # attic login atticd http://atticd/atro <token here>
  # attic use atro
  # And that created the ~/.config/attic/netrc file which I then encrypted with sops
  # I also copied the trusted-key and the substituter to the nix.conf file via nix.settings
  # the reason i did this is because ~/.config/nix/nix.conf overrides other substituters which is not great.

  # INFO: The attic login above also creates the config.toml file in ~/.config/attic/config.toml
  # I don't want to login manually, I want that to be declerative so I copied that file and encrypted it with sops
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
