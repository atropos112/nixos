{
  pkgs,
  config,
  ...
}: let
  attic_atropos_token = config.sops.secrets."attic/atropos-token".path;
  attic = "${pkgs.attic-client}/bin/attic";
in {
  environment.systemPackages = with pkgs; [
    attic-client
  ];

  # INFO: To get this token I ran
  # atticadm make-token \
  # --validity "10y" \
  # --sub "atro" \
  # --pull "atro" \
  # --push "atro" \
  # --create-cache "atro" \
  # --configure-cache "atro" \
  # --configure-cache-retention "atro" \
  # --destroy-cache "atro*" -f ./temp.toml
  # Where temp.toml is the file matching config.toml on the server.
  # You might think you can do "*" instead of "atro" but that will not work.
  sops.secrets."attic/atropos-token" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
  };

  systemd.user.services.attic-connect = {
    description = "Connect to Attic";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "connect-to-attic" ''
        ATTIC_TOKEN=$(cat ${attic_atropos_token})
        ${attic} login atticd http://atticd $ATTIC_TOKEN
        ${attic} use atro
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  systemd.services.attic-client = {
    description = "Attic watch store";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "watch-store" ''
        ATTIC_TOKEN=$(cat ${attic_atropos_token})
        ${attic} login atticd http://atticd $ATTIC_TOKEN
        ${attic} use atro
        ${attic} watch-store atticd:atro
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
