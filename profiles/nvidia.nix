{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  # INFO: These are used in the k3s hack, do not touch pls.
  environment.systemPackages = with pkgs-stable; [
    runc
    nvidia-container-toolkit
    nvtopPackages.nvidia
  ];

  atro.impermanence.global.dirs = [
    "/var/run/cdi"
  ];

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    # Can then run containers with GPU access, e.g.
    # podman run --rm --device nvidia.com/gpu=all --security-opt=label=disable ubuntu nvidia-smi -L
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
      mount-nvidia-docker-1-directories = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = lib.mkDefault true;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
