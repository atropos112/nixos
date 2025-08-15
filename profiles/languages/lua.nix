{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # lua lang server
    lua-language-server

    # lua formatter
    stylua
  ];
}
