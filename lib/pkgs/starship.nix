_: {
  home-manager.users.atropos.programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = true;

      battery = {
        disabled = false;
        unknown_symbol = "?";
        display = [
          {
            threshold = 20;
            style = "bold red";
          }
          {
            threshold = 40;
            style = "bold yellow";
            discharging_symbol = "💦 ";
          }
        ];
      };

      buf = {
        disabled = false;
        symbol = "🦬 ";
      };

      direnv = {
        disabled = true;
      };

      git_branch = {
        always_show_remote = false;
      };

      git_metrics = {
        disabled = false;
      };

      helm = {
        disabled = true;
      };

      kubernetes = {
        disabled = false;
        detect_env_vars = ["K3S_DIR"];
        format = "[$symbol$namespace]($style) in ";
      };

      memory_usage = {
        # Disabled as it doesn't understand ZFS Arc
        # and assumes it the real memory usage
        disabled = true;
        threshold = 90;
      };

      nix_shell = {
        format = "in [$symbol]($style)";
        symbol = "❄️ ";
      };

      package = {
        disabled = true;
      };

      status = {
        disabled = false;
        map_symbol = true;
      };

      sudo = {
        disabled = false;
      };
    };
  };
}
