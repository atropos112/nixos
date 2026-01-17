{pkgs-master, ...}: {
  home-manager.users.atropos.programs.opencode = {
    enable = true;
    package = pkgs-master.opencode;
  };
}
