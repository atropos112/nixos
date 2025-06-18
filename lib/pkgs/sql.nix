{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    sqlfluff

    # For interacting with postgresql
    pgcli

    # psql to connect to postgres databases
    postgresql
  ];
}
