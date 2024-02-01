{
  config,
  pkgs,
  ...
}: {
  home-manager.users.atropos.programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = pkgs.kitty;
    font = {
      name = "Comic Code Ligatures";
      size = 12;
    };
    keybindings = {
      # Fix the Ctrl/Alt left right movement across words
      "ctrl+left" = ''send_text all \x1b\x62'';
      "ctrl+right" = ''send_text all \x1b\x66'';
      "alt+left" = ''send_text all \x01'';
      "alt+right" = ''send_text all \x05'';
    };
    settings = {
      #general
      disable_ligatures = "never";
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      editor = "nvim";

      # Performance
      repaint_delay = 2;
      input_delay = 1;
      sync_to_monitor = true;

      ### Theme settings (using NixColors)
      # General
      background_opacity = "0.8";
      window_padding_width = 0;

      # General colours
      background = "#${config.colorScheme.palette.base00}";
      foreground = "#${config.colorScheme.palette.base05}";
      selection_background = "#${config.colorScheme.palette.base05}";
      selection_foreground = "#${config.colorScheme.palette.base00}";
      url_color = "#${config.colorScheme.palette.base04}";
      cursor = "#${config.colorScheme.palette.base05}";
      active_border_color = "#${config.colorScheme.palette.base03}";
      inactive_border_color = "#${config.colorScheme.palette.base01}";
      active_tab_background = "#${config.colorScheme.palette.base00}";
      active_tab_foreground = "#${config.colorScheme.palette.base05}";
      inactive_tab_background = "#${config.colorScheme.palette.base01}";
      inactive_tab_foreground = "#${config.colorScheme.palette.base04}";
      tab_bar_background = "#${config.colorScheme.palette.base01}";

      # normal colours
      color0 = "#${config.colorScheme.palette.base00}";
      color1 = "#${config.colorScheme.palette.base08}";
      color2 = "#${config.colorScheme.palette.base0B}";
      color3 = "#${config.colorScheme.palette.base0A}";
      color4 = "#${config.colorScheme.palette.base0D}";
      color5 = "#${config.colorScheme.palette.base0E}";
      color6 = "#${config.colorScheme.palette.base0C}";
      color7 = "#${config.colorScheme.palette.base05}";

      # bright colours
      color8 = "#${config.colorScheme.palette.base03}";
      color9 = "#${config.colorScheme.palette.base09}";
      color10 = "#${config.colorScheme.palette.base01}";
      color11 = "#${config.colorScheme.palette.base02}";
      color12 = "#${config.colorScheme.palette.base04}";
      color13 = "#${config.colorScheme.palette.base06}";
      color14 = "#${config.colorScheme.palette.base0F}";
      color15 = "#${config.colorScheme.palette.base07}";
    };
  };
}
