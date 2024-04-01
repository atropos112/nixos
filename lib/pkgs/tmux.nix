{pkgs, ...}: {
  home-manager.users.atropos.programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
    ];
    extraConfig = ''
      set -g @catppuccin_flavour 'macchiato'
    '';
    # extraConfig = ''
    #   set -g @open 'C-o'
    #   set-option -g default-shell /usr/bin/env zsh
    #   set -g @open-editor 'o'
    #   set -g @onedark_widgets "#{prefix_highlight} CPU: #{cpu_percentage} | NET: #{net_speed}"
    #   set -g mouse on
    # '';
  };
}
