{
  inputs,
  pkgs,
  config,
  ...
}: let
  attic_pkgs = inputs.attic.packages.${pkgs.system};
  attic_atropos_token = config.sops.secrets."attic/atropos-token".path;
in {
  environment.systemPackages = [
    attic_pkgs.attic
  ];

  sops.secrets."attic/atropos-token" = {};

  systemd.services.attic-client = {
    description = "Attic watch store";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "watch-store" ''
        #!/run/current-system/sw/bin/bash
        ATTIC_TOKEN=$(cat ${attic_atropos_token})
        ${attic_pkgs.attic}/bin/attic login atticd http://atticd:8080 $ATTIC_TOKEN
        ${attic_pkgs.attic}/bin/attic use atticd:atro
        ${attic_pkgs.attic}/bin/attic watch-store atticd:atro
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
