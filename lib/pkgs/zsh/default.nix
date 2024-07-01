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
      atuin.enableZshIntegration = true;
      # kitty.shellIntegration.enableZshIntegration = true;

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
            "kubectl"
            "docker-compose"
          ];
        };

        autosuggestion.enable = true;
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

          pi = "uv pip";
          j = "just";
          c = "clear";
          getip = "curl -s 'https://api.ipify.org'";
          cdi = "zi";
          rscp = "rsync --ignore-existing -raz --progress ";
          rssh = "/run/current-system/sw/bin/ssh";

          # cat
          cat = "bat --paging never --theme DarkNeon";
          rcat = "/run/current-system/sw/bin/cat";

          # vim
          v = "nvim";
          vim = "nvim";
          vi = "nvim";

          # git
          rbr = "git checkout $(git_main_branch) && git pull && git switch - && git rebase $(git_main_branch)";
          gmerg = "git add --all && git commit --amend --no-edit";

          # ls -> eza
          l = "eza -l --icons --git -a";
          ls = "eza --icons --git";

          # kitty based
          # s = "kitten ssh";

          # Nix based
          nxsh = ''cached-nix-shell --command zsh -p '';
        };
        initExtra = ''
          for file in ${thisDir}/*.zsh; do
            source "$file"
          done

          # if not running interactively do nothing.
          [[ $- != *i* ]] && return

          # fastfetch

          set -o vi
          set -o emacs

          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            # Set the TERM environment variable to vt100
            export TERM=xterm
          fi

          # functions
          function rebase-surface {
            # if hostname of current machine is NOT giant then exit with 1 and echo message
            if [ $(hostname) != "giant" ]; then
              echo "You are not on giant, you are on $(hostname)"
              return 1
            fi
            rsync -av --delete /home/atropos/.config/vivaldi/ surface:/persistent/home/atropos/.config/vivaldi
            rsync -av --delete /home/atropos/projects/ surface:/persistent/home/atropos/projects
            rsync -av --delete /home/atropos/nixos/ surface:/persistent/home/atropos/nixos
            rsync -av --delete /home/atropos/.config/nvim surface:/persistent/home/atropos/.config/nvim
          }

          function rebase-giant {
            if [ $(hostname) != "surface" ]; then
              echo "You are not on giant, you are on $(hostname)"
              return 1
            fi
            rsync -av --delete /home/atropos/.config/vivaldi/ giant:/persistent/home/atropos/.config/vivaldi
            rsync -av --delete /home/atropos/projects/ giant:/persistent/home/atropos/projects
            rsync -av --delete /home/atropos/nixos/ giant:/persistent/home/atropos/nixos
            rsync -av --delete /home/atropos/.config/nvim giant:/persistent/home/atropos/.config/nvim
          }

          function sssh {
              /run/current-system/sw/bin/mosh $@ -- tmux new -As atropos
          }

          function nxrn {
            cached-nix-shell --command "$1" -p "$1"
          }

          function upload {
            curl --upload-file $1 https://transfer.sh
          }

          function cd () {
              __zoxide_z "$@"
          }

          function ssh () {
            # check if $TERM = "xterm-kitty"
            if [ "$TERM" = "xterm-kitty" ]; then
              kitty +kitten ssh $@
            else
              /run/current-system/sw/bin/mosh $@
            fi
          }

          function grih {
            git rebase -i HEAD~$1
          }

          # Found this cool function here: https://news.ycombinator.com/item?id=38471822
          function frg {
            result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
                fzf --ansi \
                    --color 'hl:-1:underline,hl+:-1:underline:reverse' \
                    --delimiter ':' \
                    --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
                    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
              file=''${result%%:*}
              linenumber=$(echo "''${result}" | cut -d: -f2)
              if [[ -n "$file" ]]; then
                      $EDITOR +"''${linenumber}" "$file"
              fi
          }

          eval "$(zoxide init zsh)"
          # eval "$(fzf --zsh)"
        '';
      };
    };
  };
}
