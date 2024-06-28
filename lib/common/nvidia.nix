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
      cdi.dynamic.nvidia.enable = true;
    };
  };

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  environment.systemPackages = with pkgs-stable; [
    nvtop-nvidia
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
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
