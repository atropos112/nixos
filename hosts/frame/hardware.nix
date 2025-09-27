{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ../../profiles/impermanence/desktop.nix
  ];

  # lib.mkDefault won't work here as nixos-hardware also does lib.mkDefault
  # so have to hard set it here.
  boot.kernelPackages = pkgs.linuxPackages_6_16;

  atro = {
    boot = {
      enable = true;
    };

    diskoZfsRoot = {
      enable = true;
      hostId = "8f3aa99f";
      mode = ""; # no mirroring as it only has one drive.
      drives = [
        "nvme-Samsung_SSD_990_PRO_2TB_S7HENJ0Y411392N"
      ];
      drivePartLabels = ["x"];
      encryption = {
        enable = true;
      };
    };
  };
}
