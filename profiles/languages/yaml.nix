{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # yaml lang server
    yaml-language-server

    # yaml formatter
    yamlfix
    yamlfmt
  ];
}
