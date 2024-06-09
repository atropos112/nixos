{lib, ...}: {
  home-manager.users.atropos.programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = lib.mkForce "Comic Code Ligatures:Regular:style=Extra Bold Italic:size=12";
        pad = "4x2 center";
      };
      cursor = {
        blink = false;
        style = "block";
        beam-thickness = "2";
        underline-thickness = "2";
      };
      tweak = {
        font-monospace-warn = "no"; # reduces startup time
        sixel = "yes";
      };
    };
  };
}
