{pkgs, ...}: {
  atro.garage = {
    enable = true;
    package = pkgs.garage_2;
    secrets = {
      rpcSecret = "garage/rpcSecret";
      adminToken = "garage/adminToken";
    };
  };
}
