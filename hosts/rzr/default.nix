{pkgs, ...}: {
  imports = [
    ../../profiles/kopia/to_rzr.nix
    ./hardware.nix
    ../../lib/common
    ../../profiles/kubernetes/server.nix
    ../../profiles/kubernetes/user.nix
    ../../profiles/kubernetes/nvidia.nix
    ../../lib/pkgs/garage.nix
  ];

  atro = {
    kopia = {
      enable = true;
      runAs = "root";
      exposeWebUI = true;
      path = "/mnt/photos/";
    };
  };

  environment.systemPackages = with pkgs; [
    yt-dlp
  ];

  topology.self = {
    name = "rzr";
    interfaces = {
      tailscale0.addresses = ["rzr"];
      eth0.addresses = ["9.0.0.2"];
    };
    hardware.info = "i7-6900K, 32GB (DDR4), GTX1080Ti, K8s Master";
  };

  networking = {
    hostName = "atrorzr";
    interfaces.eth0.macAddress = "d0:50:99:96:77:de";
  };
}
