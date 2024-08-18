{
  lib,
  config,
  pkgs,
  ...
}: {
  # INFO: On nix opts it says "virtualisation.docker.enableNvidia" was replaced with hardware.nvidia-container-toolkit.enable
  # but that's not really true, docker doesn't seem to find nvidia-container-cli. The virtualisation.docker below
  # is a workaround for that, using a lot of the virtualisation.docker.enableNvidia logic.
  virtualisation.docker = {
    extraPackages = with pkgs; [
      nvidia-docker
    ];
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  # INFO: These are used in the k3s hack, do not touch pls.
  environment.systemPackages = with pkgs; [
    runc
    nvidia-container-toolkit
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
