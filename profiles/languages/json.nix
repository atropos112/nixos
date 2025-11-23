{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    biome
  ];
}
