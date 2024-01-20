{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    haproxy
  ];

  services.haproxy = {
    enable = true;
    package = pkgs.haproxy.override {withPrometheusExporter = true;};
    # Prometheus is on by default, stating it anyway just to be clear
    # Look here for more info: https://www.haproxy.com/blog/haproxy-exposes-a-prometheus-metrics-endpoint
    config = ''
      defaults
          maxconn 20000
          mode    tcp
          option  dontlognull
          timeout http-request 10s
          timeout queue        1m
          timeout connect      10s
          timeout client       86400s
          timeout server       86400s
          timeout tunnel       86400s

      frontend k3s-frontend
          bind *:7443
          mode tcp
          option tcplog
          default_backend k3s-backend

      frontend stats
          bind *:8404
          mode http
          http-request use-service prometheus-exporter if { path /metrics }
          stats enable
          stats uri /stats
          stats refresh 10s

      backend k3s-backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
          server atrorzr  9.0.0.2:6443 check
          server atro21 9.0.0.3:6443 check
          server atrosmol 9.0.0.4:6443 check
    '';
  };
}
