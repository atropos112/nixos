{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../kubernetes/node_agent.nix
    inputs.socle.nixosModules.orangepi-5
    #./hardware.nix # Non standard, typically this is done from devices/<devicename>/hardware.nix but its the same across and always should be so importing it here instead.
  ];

  # boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (pkgs.callPackage ./kernel/socle.nix {}));

  environment.systemPackages = with pkgs; [
    cilium-cli
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
}
