{pkgs, ...}: {
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
      "editor" = {
        "fontFamily" = "'Comic Code Ligatures', 'Comic Code Ligatures', Comic Code Ligatures";
        "detectIndentation" = false;
        "minimap.enabled" = false;
        "tabSize" = 2;
        "formatOnSave" = true;
      };

      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      doppler = {
        autocomplete.enable = true;
        hover.enable = true;
      };

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
      "python.testing.cwd" = ".tests";
      "vs-kubernetes" = {
        "vs-kubernetes.crd-code-completion" = "enabled";
      };
      "python.venvPath" = "\$\{workspaceFolder\}/.venv";
      "terminal.integrated.cwd" = "\$\{workspaceFolder\}";
      "terminal.integrated.env.linux" = {
        "PYTHONPATH" = "\$\{workspaceFolder\}";
      };
      "update.mode" = "none";
      "terminal.integrated.sendKeybindingsToShell" = true;
      "terminal.explorerKind" = "external";
      "terminal.integrated.enableMultiLinePasteWarning" = false;
      "gopls" = {
        "ui.semanticTokens" = true;
      };
      "python.languageServer" = "Pylance";
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = false;
        "scminput" = false;
      };
      "go.toolsManagement.autoUpdate" = true;
      "workbench.colorTheme" = "GitHub Dark";
    };
  };
}
