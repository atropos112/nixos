{pkgs, ...}: {
  home-manager.users.atropos.programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin # Theme
      vim-tmux-navigator # Allows navigation between vim and tmux
      yank # Vim like yanking
      tmux-thumbs # Allows grabbing text (like IP's, paths etc.) and pasting it
    ];
    extraConfig = ''
      # Correct colours
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Prefix key
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Theme flavour
      set -g @catppuccin_flavour 'macchiato'

      # Mouse support (just because)
      set -g mouse on

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # Vim
      set-window-option -g mode-keys vi

      ## Pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      ## Selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      ## Thumbs
      set -g @thumbs-alphabet colemak
    '';
  };
}
