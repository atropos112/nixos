{pkgs, ...}: {
  home-manager.users.atropos.programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      theme = "opencode";
      model = "anthropic/claude-sonnet-4-5-20250929";
      autoupdate = true;
    };
  };
}
