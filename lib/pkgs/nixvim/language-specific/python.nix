{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-dap-python
    ];

    extraConfigLua = ''
      require('dap-python').test_runner = 'pytest'
      require('dap-python').setup('/home/atropos/projects/pythonic/main-venv/bin/python')
    '';
  };
}
