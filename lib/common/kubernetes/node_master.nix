{pkgs, ...}: {
  imports = [
    ./node_default.nix
    ./user.nix
  ];

  atro.k3s.role = "server";

  # For kubescape
  environment.systemPackages = with pkgs; [
    runc
  ];

  home-manager.users.atropos.home.file.".kubescape/runc".source = "${pkgs.runc}/bin/runc";
}
