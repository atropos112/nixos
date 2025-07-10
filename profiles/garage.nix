{pkgs, ...}: {
  atro.garage = {
    enable = true;
    data = {
      dir = "/mnt/garage"; # Where data lives (need high capacity)
      capacity = "2T";
    };
    metadataDir = "/home/atropos/garage_metadata"; # Directory where Garage stores its metadata (need high speed)
    package = pkgs.garage_2;
    secrets = {
      rpcSecret = "garage/rpcSecret";
      adminToken = "garage/adminToken";
    };
  };
}
