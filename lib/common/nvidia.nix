{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  virtualisation.docker = {
    enableNvidia = false; # Manually implementing to use stable drivers
    package = pkgs-stable.docker;
    extraPackages = [pkgs-stable.nvidia-docker];
    extraOptions = "--default-runtime=nvidia";
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs-stable.nvidia-docker}/bin/nvidia-container-runtime";
        };
      };
    };
  };
  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  environment.systemPackages = with pkgs-stable; [
    nvtop-nvidia
    nvidia-docker
  ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = lib.mkDefault true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
