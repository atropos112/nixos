{pkgs, ...}: {
  environment.sessionVariables = {
    # For direnv to not show the log
    DIRENV_LOG_FORMAT = "";
  };
  home-manager.users.atropos = {
    home.file.".config/direnv/config.toml".text = ''
      [whitelist]
      prefix = ["/home/atropos/projects", "/home/atropos/nixos", "/home/atropos/.config/nvim"]
    '';

    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        package = pkgs.direnv;
      };
    };
  };
}
