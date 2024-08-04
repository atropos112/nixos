{inputs, ...}: let
  nixpkgs = inputs.nixpkgs-stable;
in {
  # INFO: SD image card builder here.
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"

    # For nixpkgs cache
    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  sdImage.compressImage = false;
}
