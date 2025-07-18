{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../profiles/common/basic.nix
    ../../profiles/common/server.nix
    ../../profiles/kopia/to_rzr.nix
    ../../profiles/kubernetes/server.nix
    ../../profiles/kubernetes/user.nix
    ../../profiles/kubernetes/nvidia.nix
    ../../profiles/services/garage.nix
    ../../profiles/services/syncthing.nix
    # Sadly ollama doesn't seem to work on this GPU :/
    # Getting kernel not found errors :/
    # Instead having it work through k8s.
    # ../../pkgs/ollama.nix
  ];

  # services.ollama.loadModels = [
  #   "gemma3n:latest"
  # ];

  atro = {
    kopia = {
      enable = true;
      runAs = "root";
      exposeWebUI = true;
      path = "/mnt/photos/";
    };

    garage = {
      data = {
        dir = "/mnt/garage"; # Where data lives (need high capacity)
        capacity = "2T";
      };
      metadataDir = "/home/atropos/garage_metadata"; # Directory where Garage stores its metadata (need high speed)
      rpcPublicAddr = "rzr:3901";
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
