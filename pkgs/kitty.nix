{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
in {
  home-manager.users.atropos.programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = pkgs.kitty;
    font = {
      name = lib.mkForce "Comic Code Ligatures";
      size = 12;
    };
    keybindings = {
      # Fix the Ctrl/Alt left right movement across words
      "ctrl+left" = ''send_text all \x1b\x62'';
      "ctrl+right" = ''send_text all \x1b\x66'';
      "alt+left" = ''send_text all \x01'';
      "alt+right" = ''send_text all \x05'';
    };
    keybindings = {
      # Browse scrollback buffer in nvim
      "kitty_mod+h" = "kitty_scrollback_nvim";

      # Browse output of the last shell command in nvim
      "kitty_mod+g" = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
    };
    settings = {
      # Kitty-scrollback.nvim integration
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty";
      shell_integration = "enabled";
      # kitty-scrollback.nvim Kitten alias
      action_alias = "kitty_scrollback_nvim kitten /home/atropos/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py";
      # map = [
      #   # Browse scrollback buffer in nvim
      #   "kitty_mod+h kitty_scrollback_nvim"
      #
      #   # Browse output of the last shell command in nvim
      #   "kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output"
      # ];

      # Show clicked command output in nvim
      mouse_map = "ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output";

      # Cursor trail
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";

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
      # background_opacity = "0.95";
      window_padding_width = 0;

      # General colours
      background = "#${colors.base00}";
      foreground = "#${colors.base05}";
      selection_background = "#${colors.base05}";
      selection_foreground = "#${colors.base00}";
      url_color = "#${colors.base04}";
      cursor = "#${colors.base05}";
      active_border_color = "#${colors.base03}";
      inactive_border_color = "#${colors.base01}";
      active_tab_background = "#${colors.base00}";
      active_tab_foreground = "#${colors.base05}";
      inactive_tab_background = "#${colors.base01}";
      inactive_tab_foreground = "#${colors.base04}";
      tab_bar_background = "#${colors.base01}";

      # normal colours
      color0 = "#${colors.base00}";
      color1 = "#${colors.base08}";
      color2 = "#${colors.base0B}";
      color3 = "#${colors.base0A}";
      color4 = "#${colors.base0D}";
      color5 = "#${colors.base0E}";
      color6 = "#${colors.base0C}";
      color7 = "#${colors.base05}";

      # bright colours
      color8 = "#${colors.base03}";
      color9 = "#${colors.base09}";
      color10 = "#${colors.base01}";
      color11 = "#${colors.base02}";
      color12 = "#${colors.base04}";
      color13 = "#${colors.base06}";
      color14 = "#${colors.base0F}";
      color15 = "#${colors.base07}";
    };
  };
}
