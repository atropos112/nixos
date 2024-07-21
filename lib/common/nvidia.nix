{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  virtualisation = {
    docker = {
      enableNvidia = true;
    };
    containers = {
      enable = true;
    };
  };

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  environment.systemPackages = with pkgs-stable; [
    nvtopPackages.nvidia
    runc
  ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = lib.mkDefault true;
      powerManagement.finegrained = false;
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
