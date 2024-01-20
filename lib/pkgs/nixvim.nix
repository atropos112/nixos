{inputs, ...}: {
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

    colorschemes.onedark.enable = true;
    plugins = {
      lightline.enable = true;
      luasnip.enable = true;
      treesitter.enable = true;

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
                elseif luasnip.expandable() then
                  luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif check_backspace() then
                  fallback()
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
