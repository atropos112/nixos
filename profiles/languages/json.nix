{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nodePackages.jsonlint
    biome
  ];
}
