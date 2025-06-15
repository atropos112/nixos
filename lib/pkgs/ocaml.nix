{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opam
    dune_3
    ocaml
    ocamlPackages.utop
    ocamlPackages.ocaml-lsp
    ocamlPackages.ocamlformat
    ocamlPackages.earlybird
  ];

  home-manager.users.atropos = {
    programs = {
      opam = {
        enable = true;
        package = pkgs.opam;
        enableZshIntegration = true;
      };
    };
  };
}
