{pkgs, ...}: let
  thisDir = ./.;
in {
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    # Fuzzy selector, need for the zsh plugin
    fzf

    zsh-fzf-tab
    zsh-you-should-use
    zsh-syntax-highlighting
  ];

  home-manager.users.atropos = {
    programs = {
      atuin.enableZshIntegration = true;
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
            "kubectl"
            "docker-compose"
          ];
        };

        autosuggestion.enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        # INFO: These file paths are found by installing it first with bogus file
        # and then going to ~/.config/zsh/plugins and finding the plugin we want within which we have share/... path that we should put here.
        plugins = [
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
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.zsh-syntax-highlighting;
            file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
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
          cat = "bat --paging never --theme DarkNeon --style plain";
          rcat = "/run/current-system/sw/bin/cat";

          # fzf
          fz = ''fzf --preview "bat --style numbers --color always {}" --bind "enter:execute(vim {})+abort"'';

          fzkill = "kill -9 $(ps -ef | fzf | awk '{print $2}')";
          # vim
          v = "nvim";
          vim = "nvim";
          vi = "nvim";

          # templates
          template-python = "copier copy git@github.com:atropos112/template-python-pkg.git";

          # git
          rbr = "git checkout $(git_main_branch) && git pull && git switch - && git rebase $(git_main_branch)";
          gmerg = "git add --all && git commit --amend --no-edit";

          # ls -> eza
          l = "eza -l --icons --git -a";
          ls = "eza --icons --git";

          # kitty based
          s = "kitten ssh";

          # Nix based
          nxsh = ''cached-nix-shell --command zsh -p '';
          ns = ''nix-search'';

          y = "yazi";

          cp = "${pkgs.xcp}/bin/xcp -r";

          watch = "viddy";
          wch = "viddy";

          # Have to sudo for access, and have to use tiny-skia as otherwise it shows black window.
          sniff = "sudo -E ICED_BACKEND=tiny-skia sniffnet";
        };
        initContent = ''
          # If not running interactively do nothing.
          # This is super important to avoid errors. and also avoid scripts executing with aliases.
          [[ $- != *i* ]] && return


          # Sourcsing all all .sh files.
          for zsh_file in ${thisDir}/**/*.sh ${thisDir}/*.sh; do
            # Check if the file actually exists to avoid errors
            if [ -f "$zsh_file" ]; then
            source "$zsh_file"
          fi
          done

          if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
            fastfetch
          fi
        '';
      };
    };
  };
}
