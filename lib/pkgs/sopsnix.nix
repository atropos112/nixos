{
  inputs,
  lib,
  config,
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
    defaultSopsFile = ../../secrets/secrets.yaml;
    # WARN: This is the default path, it might be overwritten.
    # It does in impermanence for example.
    age.sshKeyPaths = lib.mkDefault ["/root/.ssh/id_ed25519"];

    # Secrets that don't fit in other modules/pkgs
    secrets = {
      "wakatime/cfg" = {
        owner = config.users.users.atropos.name;
        path = "/home/${config.users.users.atropos.name}/.wakatime.cfg";
      };
      "tailscale/key" = {};
    };
  };
}
