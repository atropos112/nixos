{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # lua lang server
    lua-language-server

    # lua formatter
    stylua

    # Luarocks is used in many places
    lua51Packages.luarocks
  ];
}
