{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.statix.packages.${pkgs.stdenv.hostPlatform.system}.statix
    inputs.nil_ls.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nil
    pkgs.deadnix # Has a flake, but is broken on master.
    pkgs.nix-output-monitor
  ];
}
