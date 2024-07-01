{
  inputs,
  pkgs,
  ...
}: let
  eza_pkgs = inputs.eza.packages.${pkgs.system};
in {
  environment.systemPackages = with eza_pkgs; [
    default
  ];
}
