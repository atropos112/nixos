{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.atropos.programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = true;
    mutableExtensionsDir = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      skellock.just
      golang.go
      github.copilot
      wakatime.vscode-wakatime
      haskell.haskell
      justusadam.language-haskell
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.vscode-pylance
      ms-python.python
      njpwerner.autodocstring
      redhat.vscode-yaml
      bbenoist.nix
      jnoortheen.nix-ide
      skellock.just
      tamasfe.even-better-toml
      github.github-vscode-theme
      kamadorueda.alejandra
      ms-python.black-formatter
      ms-python.isort
    ];
    userSettings = {
      "editor.tabSize" = 2;
      "editor.minimap.enabled" = false;

      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      "doppler.autocomplete.enable" = true;
      "doppler.hover.enable" = true;

      "isort.args" = ["--profile" "black"];

      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = false;
      };
      "[dockerfile]" = {
        "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
      };
      "alejandra.program" = "alejandra";
      "testing.alwaysRevealTestOnStateChange" = true;
      "window.titleBarStyle" = "custom";

      "window.menuBarVisibility" = "visible";
      "window.zoomLevel" = 1;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "vs-kubernetes" = {
        "vs-kubernetes.crd-code-completion" = "enabled";
      };
      "terminal.integrated.cwd" = "\$\{workspaceFolder\}";
      "update.mode" = "none";
      "terminal.integrated.sendKeybindingsToShell" = true;
      "terminal.explorerKind" = "external";
      "terminal.integrated.enableMultiLinePasteWarning" = false;
      "gopls" = {
        "ui.semanticTokens" = true;
      };

      # PYTHON
      "python.testing.cwd" = ".tests";
      "terminal.integrated.env.linux" = {
        "PYTHONPATH" = "\$\{workspaceFolder\}";
      };
      "python.venvPath" = "\$\{workspaceFolder\}/.venv";
      "python.languageServer" = "Pylance";
      "python.analysis.inlayHints.functionReturnTypes" = true;
      "python.analysis.inlayHints.pytestParameters" = true;
      "python.analysis.inlayHints.variableTypes" = true;

      # COPILOT
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = false;
        "scminput" = false;
      };
      "go.toolsManagement.autoUpdate" = true;
      "workbench.colorTheme" = lib.mkForce "GitHub Dark";
    };
  };
}
