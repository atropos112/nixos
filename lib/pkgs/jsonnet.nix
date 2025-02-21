{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # The basics
    jsonnet

    # The package manager
    jsonnet-bundler

    # LSP
    jsonnet-language-server
  ];

  home-manager.users.atropos.programs.zsh.shellAliases = {
    jn = "jsonnet";
    jnfmt = "jsonnetfmt";
  };
}
