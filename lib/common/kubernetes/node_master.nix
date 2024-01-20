_: {
  imports = [
    ./node_default.nix
    ./user.nix
  ];

  atro.k3s.role = "server";
}
