{pkgs, ...}: {
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:12346"
      "--feature.community-components.enabled"
      "--disable-reporting"
    ];
    package = pkgs.alloy;
    configPath = ./config.alloy;
  };
}
