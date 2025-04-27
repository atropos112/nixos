{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../lib/common/kubernetes/node.nix
    ../../lib/common/kubernetes/user.nix
    ../../lib/modules/kopia.nix
    # ../../lib/pkgs/ollama.nix # Running via k8s instead
  ];

  atro = {
    k3s.role = "server";

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

  system.activationScripts.makeNvidiaK3s = ''
    mkdir -p /var/lib/rancher/k3s/agent/etc/containerd/
    cp ${./k3s_config.toml.tmpl} /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
  '';
}
