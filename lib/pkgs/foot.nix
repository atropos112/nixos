{config, ...}: {
  home-manager.users.atropos.programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        # font = "JetBrainsMono Nerd Font:Bold:style=Extra Bold Italic:size=12";
        # font = "BlexMono Nerd Font:Bold:style=Extra Bold Italic:size=12";
        font = "Comic Code Ligatures:Regular:style=Extra Bold Italic:size=12";
        # font = "LiterationMono Nerd Font:Bold:style=Bold Italic:size=12";
        # font = "Iosevka Nerd Font:Bold:style=Bold Italic:size=12";
        # font = "SauceCodePro Nerd Font:Bold:style=BoldItalic :size=12";
        # font = "Liga SFMono Nerd Font:Bold:style=Bold Italic:size=12";
        pad = "4x2 center";
      };
      cursor = {
        # color = "1A1826 D9E0EE"; # Cattpuccin
        # color = "a9b1d6 f5f5f5"; # Decay
        # color = "a9b1d6 f5f5f5"; # Dark-decay
        # color = "a5b6cf cbced3"; # Decayce
        # color = "c5c8cd 101419"; # Light-decay
        # color = "1a1b26 c0caf5"; # Lunar
        # color = "192330 cdcecf"; # Nightfox
        # color = "161616 f2f4f8"; # Carbonfox
        # color = "3760bf b6bfe2"; # Tokyonight
        #color = "11121d a0a8cd"; # Tokyodark
        color = "161616 ffffff"; # Oxocarbon
        # color = "292a37 d9e0ee"; # Jabuti

        blink = false;
        style = "block";
        beam-thickness = "2";
        underline-thickness = "2";
      };
      colors = {
        #alpha = "0.9"; # transparency
        background = "${config.colorScheme.palette.base00}";
        foreground = "${config.colorScheme.palette.base05}";
        regular0 = "${config.colorScheme.palette.base00}";
        regular1 = "${config.colorScheme.palette.base08}";
        regular2 = "${config.colorScheme.palette.base0B}";
        regular3 = "${config.colorScheme.palette.base0A}";
        regular4 = "${config.colorScheme.palette.base0D}";
        regular5 = "${config.colorScheme.palette.base0E}";
        regular6 = "${config.colorScheme.palette.base0C}";
        regular7 = "${config.colorScheme.palette.base05}";
        bright0 = "${config.colorScheme.palette.base03}";
        bright1 = "${config.colorScheme.palette.base09}";
        bright2 = "${config.colorScheme.palette.base01}";
        bright3 = "${config.colorScheme.palette.base02}";
        bright4 = "${config.colorScheme.palette.base04}";
        bright5 = "${config.colorScheme.palette.base06}";
        bright6 = "${config.colorScheme.palette.base0F}";
        bright7 = "${config.colorScheme.palette.base07}";
      };
      tweak = {
        font-monospace-warn = "no"; # reduces startup time
        sixel = "yes";
        # grapheme-shaping = "yes";
      };
    };
  };
}
