{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opam
    dune_3
    ocaml
    ocamlPackages.utop
    ocamlPackages.ocaml-lsp
    ocamlPackages.earlybird
  ];

  home-manager.users.atropos = {
    programs = {
      zsh = {
        initContent = ''
          eval $(opam env)
        '';
      };
    };
  };
}
