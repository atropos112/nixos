{pkgs, ...}: let
  thisDir = ../zsh; # Bit silly, you'd think you can just write "." or "./" but nope.
in {
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    # Nice theme for ZSH
    zsh-powerlevel10k

    # Fuzzy selector, need for the zsh plugin
    fzf

    zsh-fzf-tab
    zsh-you-should-use
  ];

  home-manager.users.atropos = {
    programs = {
      direnv.enableZshIntegration = true;
      # atuin.enableZshIntegration = true; # WARN: Atuin is not working well, sqlite is timing out some ZFS-sqlite issue. Once daemon works this can be enabled.
      kitty.shellIntegration.enableZshIntegration = true;

      zsh = {
        enable = true;
        dotDir = ".config/zsh";
        oh-my-zsh = {
          enable = true;
          # Can find a full list of plugins here https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
          # Plugins not on that list (like you-should-use) typically have to be installed manually
          # which is where the non-oh-my-zsh plugins come in (look at plugins below), less overhead, and less fuss to do them separately.
          plugins = [
            "git"
            "extract"
            "fzf" # WARN: This is temporary solution until atuin works again.
            "kubectl"
            "docker-compose"
          ];
        };

        enableAutosuggestions = true;
        enableCompletion = true;
        enableVteIntegration = true;
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
          {
            name = "zsh-you-should-use";
            src = pkgs.zsh-you-should-use;
            file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
          }
        ];

        shellAliases = {
          # general
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";

          j = "just";
          c = "clear";
          getip = "curl -s 'https://api.ipify.org'";
          cdi = "zi";
          rscp = "rsync --ignore-existing -raz --progress ";

          # cat
          cat = "bat --paging never --theme DarkNeon";
          rcat = "/run/current-system/sw/bin/cat";

          # vim
          v = "nvim";
          vim = "nvim";
          vi = "nvim";

          # git
          rebasebr = "git checkout $(git_main_branch) && git pull && git switch - && git rebase $(git_main_branch)";

          # ls -> eza
          ls = "eza";
          ll = "eza -l";
          la = "eza -la";

          # kitty based
          s = "kitten ssh";
        };
        initExtra = ''
          for file in ${thisDir}/*.zsh; do
            source "$file"
          done

          # if not running interactively do nothing.
          [[ $- != *i* ]] && return

          fastfetch

          set -o vi
          set -o emacs

          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            # Set the TERM environment variable to vt100
            export TERM=xterm
          fi

          # functions
          function sssh {
              /run/current-system/sw/bin/mosh $@ -- tmux new -As atropos
          }

          function upload {
            curl --upload-file $1 https://transfer.sh
          }

          function cd () {
              __zoxide_z "$@"
          }

          function grih {
            git rebase -i HEAD~$1
          }

          eval "$(zoxide init zsh)"
        '';
      };
    };
  };
}
