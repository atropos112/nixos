{inputs, ...}: let
  nixpkgs = inputs.nixpkgs-unstable;
  nixpkgs-config = {
    allowUnfree = true;
    allowBroken = false;
  };
in {
  home-manager.users.atropos.nixpkgs.config = nixpkgs-config;
  home-manager.users.root.nixpkgs.config = nixpkgs-config;

  # Basic Nix configuration
  nixpkgs.config = nixpkgs-config;
  nix = {
    settings = {
      download-buffer-size = 524288000;
      log-lines = 25; # The default 10 is too little.
      # download-buffer-size = 1024 * 1024 * 1024; # 1024 MiB, default is 64 MiB
      connect-timeout = 5; # Fallback quickly if substituters are not available.
      trusted-users = ["root" "atropos"];
      auto-optimise-store = true;
      fallback = true;
      substituters = [
        "http://atticd/atro" # My attic server
        "https://hyprland.cachix.org" # Hyprland Cachix server
        "https://nix-community.cachix.org" # Nix community Cachix server
        "https://devenv.cachix.org" # Devenv Cachix server
        "https://nixpkgs-python.cachix.org" # Python Cachix server
        "https://statix.cachix.org" # Statix Cachix server
      ];

      trusted-public-keys = [
        "atro:CZjIVN4tdA+5jmICWlv7JfwIfOivJmBjatsqmaCOHK8=" # My attic server
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Hyprland Cachix server
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # Nix community Cachix server
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" # Devenv Cachix server
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=" # Python Cachix server
        "statix.cachix.org-1:Z9E/g1YjCjU117QOOt07OjhljCoRZddiAm4VVESvais=" # Statix Cachix server
      ];

      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    registry.nixpkgs.flake = nixpkgs;
    nixPath = ["nixpkgs=${inputs.nixpkgs-unstable}"];
  };
}
