{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  environment.systemPackages = with pkgs; [
    ssh-to-age
    age
    sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # WARN: This is the default path, it might be overwritten.
    # It does in impermanence for example.
    age.sshKeyPaths = lib.mkDefault ["/root/.ssh/id_ed25519"];
  };
}
