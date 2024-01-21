_: {
  programs.nixvim = {
    plugins = {
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
  };
}
