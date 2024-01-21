# Dap = Debug Adapter Protocol
# Dap is a protocol that allows editors to communicate with debuggers
# For NixVim use this provides the debugging functionality.
_: {
  programs.nixvim = {
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
      dap = {
        enable = true;
        extensions = {
          dap-go.enable = true;
          dap-ui.enable = true;
        };
      };
    };
  };
}
