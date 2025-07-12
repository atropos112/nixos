{pkgs, ...}: {
  atro.garage = {
    enable = true;
    package = pkgs.garage_2;
    allowUser = true;
    secrets = {
      rpcSecret = "garage/rpcSecret";
      adminToken = "garage/adminToken";
    };
  };
}
