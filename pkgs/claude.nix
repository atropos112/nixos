{pkgs-master, ...}: {
  environment.sessionVariables.CLAUDE_CONFIG_DIR = "/persistent/home/atropos/projects/claude";

  # For mkOutOfStoreSymlink have to use home-manager's config.lib
  home-manager.users.atropos = {config, ...}: {
    home.file = {
      ".claude.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "/persistent/home/atropos/.claude.json";
        force = true;
      };
      ".claude.json.backup" = {
        source = config.lib.file.mkOutOfStoreSymlink "/persistent/home/atropos/.claude.json.backup";
        force = true;
      };
    };

    programs.claude-code = {
      enable = true;
      package = pkgs-master.claude-code;
    };
  };
}
