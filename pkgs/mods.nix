{
  pkgs,
  config,
  lib,
  ...
}: let
  apiTokenPath = config.sops.secrets."llm/anthropic".path;
in {
  sops.secrets."llm/anthropic" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
  };

  home-manager.users.atropos.programs = {
    zsh.shellAliases = {
      # Passing in secrets regardless if using anthropic or ollama just because its easier.
      m = "ANTHROPIC_API_KEY=$(cat ${apiTokenPath}) ${lib.getExe pkgs.mods}";
      mc = "m -C";
    };
    mods = {
      enable = true;
      package = pkgs.mods;
      enableZshIntegration = true;
      settings = {
        # Your desired level of fanciness.
        fanciness = 10;
        include-prompt = 0;
        include-prompt-args = false;
        max-retries = 5;
        no-limit = false;
        status-text = "Generating";
        # Temperature (randomness) of results, from 0.0 to 2.0.
        temp = 1;
        # Theme to use in the forms. Valid units are: 'charm', 'catppuccin', 'dracula', and 'base16'
        theme = "charm";
        # TopK, only sample from the top K options for each subsequent token.
        topk = 50;
        # TopP, an alternative to temperature that narrows response, from 0.0 to 1.0.
        topp = 1;
        default-model = "claude-sonnet-4-5";
        apis = {
          anthropic = {
            api-key = null;
            api-key-env = "ANTHROPIC_API_KEY";
            base-url = "https://api.anthropic.com/v1";
            models = {
              claude-sonnet-4-20250514 = {
                max-input-chars = 680000;
              };
              claude-opus-4-20250514 = {
                max-input-chars = 680000;
              };
            };
          };
          ollama = {
            base-url = "http://ollama:11434/api";
            models = {
              "gemma3n:latest" = {
                model = "gemma3n:latest";
                max-input-chars = 650000;
              };
            };
          };
        };
      };
    };
  };
}
