{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gojq
    yq
    xq
  ];

  home-manager.users.atropos.programs = {
    zsh = {
      plugins = [
        {
          name = "fzf-jq";
          src = pkgs.fetchFromGitHub {
            owner = "reegnz";
            repo = "jq-zsh-plugin";
            rev = "48befbcd91229e48171d4aac5215da205c1f497e";
            sha256 = "sha256-q/xQZ850kifmd8rCMW+aAEhuA43vB9ZAW22sss9e4SE=";
          };
          file = "jq.plugin.zsh";
        }
      ];

      shellAliases.jq = "gojq";
    };
  };
}
