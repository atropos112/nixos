_: {
  services.k3s.containerdConfigTemplate = ''
    version = 2

    [plugins."io.containerd.internal.v1.opt"]
      path = "/var/lib/rancher/k3s/agent/containerd"
    [plugins."io.containerd.grpc.v1.cri"]
      stream_server_address = "127.0.0.1"
      stream_server_port = "10010"
      enable_selinux = false
      enable_unprivileged_ports = true
      enable_unprivileged_icmp = true
      sandbox_image = "rancher/mirrored-pause:3.6"

    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      disable_snapshot_annotations = true




    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      runtime_type = "io.containerd.runc.v2"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true

    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = "/var/lib/rancher/k3s/agent/etc/containerd/certs.d"


    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."nvidia"]
      runtime_type = "io.containerd.runc.v2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."nvidia".options]
      BinaryName = "/run/current-system/sw/bin/nvidia-container-runtime.cdi"
      SystemdCgroup = true
  '';
}
