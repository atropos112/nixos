{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  # INFO: On nix opts it says "virtualisation.docker.enableNvidia" was replaced with hardware.nvidia-container-toolkit.enable
  # but that's not really true, docker doesn't seem to find nvidia-container-cli. The virtualisation.docker below
  # is a workaround for that, using a lot of the virtualisation.docker.enableNvidia logic.
  virtualisation.docker = {
    # INFO: Having to use pkgs-stable because for reasons I am not quiet sure of in nixpkgs-unstable the
    # nvidia-container-toolkit no longer has nvidia-container-runtime in it (somehow)
    # You can run `nvidia-ctk runtime configure --runtime=containerd --enable-cdi`
    # or `nvidia-ctk runtime configure --runtime=containerd`
    # and then see what was generated in the config.toml file but it will be pointing
    # to nvidia-container-runtime path that is infact missing the nvidia-container-runtime, not sure whats up with that.
    extraPackages = with pkgs-stable; [
      nvidia-container-toolkit
    ];
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs-stable.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

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
