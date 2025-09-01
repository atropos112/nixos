{pkgs-stable, ...}: {
  services.unbound = {
    enable = true;
    package = pkgs-stable.unbound;
    resolveLocalQueries = false;
    settings = {
      server = {
        port = "5553";
        interface = ["0.0.0.0"];
        access-control = [
          "0.0.0.0/0 allow" # Allow all IPv4
        ];
        do-ip4 = "yes";
        do-udp = "yes";
        do-tcp = "yes";
        verbosity = "1"; # Increase for debugging
      };
    };
  };

  users = {
    groups.unbound.gid = 988;

    users = {
      unbound = {
        uid = 996;
        group = "unbound";
      };
    };
  };
}
