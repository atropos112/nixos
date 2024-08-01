{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    s3cmd
    s4cmd
  ];
  sops.secrets = {
    "s3cfg" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
      mode = "0600";
      path = "/home/atropos/.s3cfg";
    };
  };
}
