{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    keepalived
    killall
  ];

  services.keepalived = {
    enable = true;
    vrrpScripts = {
      "chk_haproxy" = {
        script = "${pkgs.killall}/bin/killall -0 haproxy";
        interval = 2;
      };
    };
    vrrpInstances = {
      "haproxy-vip" = {
        interface = "eth0";
        state = "MASTER";
        virtualRouterId = 36; # arbitrary, must be used to distinguish between instances on same NIC
        virtualIps = [
          {
            addr = "9.0.0.110/24";
          }
        ];
        trackScripts = ["chk_haproxy"];
      };
    };
  };
}
