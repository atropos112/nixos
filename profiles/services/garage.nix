{pkgs, ...}: {
  atro.garage = {
    enable = true;
    package = pkgs.garage_2;
    secrets = {
      rpcSecret = "garage/rpcSecret";
      adminToken = "garage/adminToken";
    };

    alloy.config = [
      {
        priority = 100;
        value = ''
          prometheus.scrape "garage" {
            forward_to = [otelcol.receiver.prometheus.default.receiver]
            scrape_interval = "15s"
            scrape_timeout = "4s"
            metrics_path    = "/metrics"
            targets = [
              {"__address__" = "127.0.0.1:3903" },
            ]
        '';
      }
    ];
  };
}
