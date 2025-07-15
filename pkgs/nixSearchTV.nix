{
  inputs,
  pkgs,
  lib,
  ...
}: let
  nstPkg = inputs.nix-search-tv.packages.${pkgs.system}.default;
  nst = lib.getExe nstPkg;
  fzf = lib.getExe pkgs.fzf;
in {
  environment.systemPackages = [
    inputs.nix-search-tv.packages.${pkgs.system}.default
  ];

  home-manager.users.atropos.programs.zsh.shellAliases = {
    ns = ''${nst} print | ${fzf} --preview '${nst} preview {}' --scheme history'';
  };
}
