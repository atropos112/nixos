{
  inputs,
  pkgs,
  ...
}: let
  colmena_pkgs = inputs.colmena.packages.${pkgs.system};
in {
  environment.systemPackages = with colmena_pkgs; [
    colmena
  ];
}
