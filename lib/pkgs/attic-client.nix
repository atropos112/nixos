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

  # INFO: To get this token I ran
  # atticadm make-token \
  # --validity "10y" \
  # --sub "atro*" \
  # --pull "atro*" \
  # --push "atro*" \
  # --create-cache "atro*" \
  # --configure-cache "atro*" \
  # --configure-cache-retention "atro*" \
  # --destroy-cache "atro*" -f ./temp.toml
  # Where temp.toml is the file matching config.toml on the server.
  # You might think you can do "*" instead of "atro*" but that will not work.
  sops.secrets."attic/atropos-token" = {};

  systemd.services.attic-client = {
    description = "Attic watch store";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "watch-store" ''
        #!/run/current-system/sw/bin/bash
        ATTIC_TOKEN=$(cat ${attic_atropos_token})
        ${attic_pkgs.attic}/bin/attic login atticd https://atticd.atro.xyz $ATTIC_TOKEN
        ${attic_pkgs.attic}/bin/attic watch-store atticd:atro
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
