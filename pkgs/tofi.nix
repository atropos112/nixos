{pkgs, ...}: {
  home-manager.users.atropos.home.file.".config/tofi/config".text = ''
    selection-color = #038fa8
    width = 100%
    height = 100%
    border-width = 0
    outline-width = 0
    padding-left = 35%
    padding-top = 35%
    result-spacing = 25
    num-results = 7
    background-color = #000A
  '';
  environment.systemPackages = [pkgs.tofi];
}
