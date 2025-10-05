_: {
  imports = [
    ./basic.nix
  ];

  atro.impermanence = {
    global = {
      dirs = [
        "/opt/local-path-provisioner" # Local path provisioner
        "/etc/rancher/k3s" # K3s config
        "/etc/rancher/node" # K3s node config
        "/var/lib/rancher/k3s" # K3s data
        "/var/lib/longhorn" # Longhorn storage for persistent volumes
        "/stuff_pipeline" # Stuff pipeline data
      ];
    };
    home = {
      dirs = [
        ".ollama" # Ollama cache
      ];
    };
  };
}
