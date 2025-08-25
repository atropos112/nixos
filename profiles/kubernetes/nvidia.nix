{
  config,
  lib,
  pkgs,
  ...
}: {
  # Got this solution from https://github.com/NixOS/nixpkgs/issues/288037#issuecomment-3153078086
  # Not quiet sure how it works, but it does. ¯\_(ツ)_/¯
  # Such is life of an nvidia card owner.
  services.k3s.containerdConfigTemplate = ''
    {{ template "base" . }}

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "${lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package}/bin/nvidia-container-runtime"
  '';

  systemd.services.k3s.path = ["${lib.getBin pkgs.libnvidia-container}" "${lib.getBin config.hardware.nvidia-container-toolkit.package}"];
}
