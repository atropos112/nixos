{
  pkgs,
  lib,
  config,
  ...
}: {
  virtualisation.docker = {
    enableNvidia = true;
    extraOptions = "--default-runtime=nvidia";
  };
  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = lib.mkDefault true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    nvtop-nvidia
  ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
