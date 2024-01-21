_: {
  programs.nixvim = {
    plugins = {
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
    };
  };
}
