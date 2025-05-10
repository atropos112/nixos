{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opam
    dune_3
    ocaml
    ocamlPackages.utop
  ];
}
