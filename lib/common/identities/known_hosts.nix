{config, ...}: let
  inherit (builtins) mapAttrs;
  inherit (config.networking) hostName;

  secretKeyString = name: "hostKeys/${name}/privateKey";
  publicKeyString = name: "hostKeys/${name}/publicKey";

  secretKeyPath = name: config.sops.secrets.${secretKeyString name}.path;
  publicKeyPath = name: config.sops.secrets.${publicKeyString name}.path;
in {
  # INFO: Ensuring the key on the machine where NixOs is deployed is decleared.
  # This will allow us to statically define known hosts below.

  sops.secrets = {
    "${secretKeyString hostName}" = {};
    "${publicKeyString hostName}" = {};
  };

  environment.etc = {
    "private-host-key" = {
      enable = true;
      target = "ssh/ssh_host_ed25519_key";
      source = secretKeyPath hostName;
      uid = 0;
      gid = 0;
      mode = "0600";
    };
    "public-host-key" = {
      enable = true;
      target = "ssh/ssh_host_ed25519_key.pub";
      source = publicKeyPath hostName;
      uid = 0;
      gid = 0;
      mode = "0644";
    };
  };

  # WARN: In order to have pure eval, must provide these keys statically and not via SOPS sadly.
  programs.ssh.knownHosts = mapAttrs (_: value: {publicKey = value;}) {
    "giant" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEj/sPZDcB3y8Y/ZKsVEh+4dRt/nVyaGVPVxXr2weN40 root@giant";
    "rzr" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAl6IsW8grB3/X+iW9Lp9dTemuUxH9B182Mgkfwjinn root@nixos";
    "smol" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGp/zqplehZJIf3TTXyisP3leDCmpYBq5LIWXP92cTJC root@nixos";
    "a21" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSZed79HYBPXUTtTHAmcor4gWsa/RdalCb1PqXtu8d0 root@nixos";
    "opi1" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4ZbA0tpt00ud7x5SujrRdnCZZ1TBzeKFlaC4ZCGuHs root@orangepi5";
    "opi2" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoOR8HM7RmgRoeFX06COaFSYuFEjZo+jYWXVYQx/1BY root@orangepi5";
    "opi3" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLjRiTcGquGvFOGYm/w4kbnqkzTQGoFYLHyWd9gYIhQ root@orangepi5";
    "opi4" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPT3/T4GHh/Qzb2gp7PABxdUdUvR64atkbV6PNoicro3 root@orangepi5";

    "github.com" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
  };
}
