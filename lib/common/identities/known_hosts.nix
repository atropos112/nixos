{config, ...}: let
  inherit (config.networking) hostName;
  secretKeyPath = "hostKeys/${hostName}/privateKey";
in {
  sops.secrets.${secretKeyPath} = {};

  environment.etc = {
    "private-host-key" = {
      enable = true;
      target = "/etc/ssh/ssh_host_ed25519_key";
      source = config.sops.secrets.${secretKeyPath}.path;
      uid = 0;
      gid = 0;
      mode = "0600";
    };
  };

  # programs.ssh.knownHosts = {
  #   "giant".publicKey = giant.publicKeyHost;
  # };
}
