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

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
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
