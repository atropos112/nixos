{inputs, ...}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
    ./dap.nix
    ./cmp.nix
    ./lsp.nix
    ./language-specific
  ];
  programs.nixvim = {
    enable = true;
    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };
    globals.mapleader = ","; # Sets the leader key to comma

    colorschemes.onedark.enable = true;

    plugins = {
      lightline.enable = true;
      luasnip.enable = true;
      treesitter.enable = true;

      markdown-preview = {
        enable = true;
        autoClose = false; # It closes entire browser not just one tab...
        autoStart = true;
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
        keymaps = {
          "<C-g>" = {
            action = "git_files";
            desc = "Telescope Git Files";
          };
          "<leader>fg" = "live_grep";
        };
      };

      copilot-lua = {
        enable = true;
        suggestion = {
          autoTrigger = true;
          keymap.accept = "<C-CR>";
        };
      };

      toggleterm = {
        enable = true;
        direction = "horizontal";
        size = 20;
        openMapping = "<C-p>";
        shadeTerminals = true;
        persistSize = true;
      };
    };
    clipboard.register = "unnamedplus";
  };
}
