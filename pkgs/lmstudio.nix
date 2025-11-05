{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    lmstudio
  ];

  atro.impermanence.home.dirs = [
    ".lmstudio"
  ];
}
