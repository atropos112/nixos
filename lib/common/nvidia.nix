{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  virtualisation.docker = {
    enableNvidia = true;
    # extraOptions = "--default-runtime=nvidia";
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
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
