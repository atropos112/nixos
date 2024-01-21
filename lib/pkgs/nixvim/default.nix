{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];
  programs.nixvim = {
    enable = true;
    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };
    globals.mapleader = ","; # Sets the leader key to comma
    extraPlugins = with pkgs.vimPlugins; [
      vim-go
    ];

    keymaps = [
      {
        mode = "n";
        key = "<Leader>c";
        action = ":DapContinue<CR>";
      }
      {
        mode = "n";
        key = "<Leader>0";
        action = ":DapStepOver<CR>";
      }
      {
        mode = "n";
        key = "<Leader>-";
        action = ":DapStepInto<CR>";
      }
      {
        mode = "n";
        key = ''<Leader>\'';
        action = ":DapStepOut<CR>";
      }
      {
        mode = "n";
        key = "<Leader>b";
        action = ":DapToggleBreakpoint<CR>";
      }
      {
        mode = "n";
        key = "<Leader>q";
        action = ":DapTerminate<CR>";
      }
    ];

    colorschemes.onedark.enable = true;

    extraConfigLua = ''
      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    ''; # Enable the dapui sidebar

    plugins = {
      lightline.enable = true;
      luasnip.enable = true;
      treesitter.enable = true;

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

      dap = {
        enable = true;
        extensions = {
          dap-go.enable = true;
          dap-ui.enable = true;
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

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          gopls = {
            enable = true;
            autostart = true;
            installLanguageServer = true;
          };
        };
      };

      lsp-format.enable = true;
      cmp_luasnip.enable = true;

      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        snippet.expand = "luasnip";
        sources = [
          {name = "nvim_lsp";}
          {name = "buffer";}
          {name = "path";}
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };
    };
    clipboard.register = "unnamedplus";
  };
}
