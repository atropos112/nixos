{inputs, ...}: let
  nixpkgs = inputs.nixpkgs-unstable;
in {
  # Basic Nix configuration
  nix = {
    settings = {
      log-lines = 25; # The default 10 is too little.
      connect-timeout = 5; # Fallback quickly if substituters are not available.
      trusted-users = ["root" "atropos"];
      auto-optimise-store = true;
      substituters = [
        "http://atticd/atro" # My attic server
        "https://hyprland.cachix.org" # Hyprland Cachix server
        "https://staging.attic.rs/attic-ci" # Attic staging server
      ];

      trusted-public-keys = [
        "atro:R7GFHBzb+86ECFOkCCTX3omPBbXCp6uTdtf5whXWI6o=" # My attic server
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Hyprland Cachix server
        "attic-ci:U5Sey4mUxwBXM3iFapmP0/ogODXywKLRNgRPQpEXxbo=" # Attic staging server
      ];

      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
    registry.nixpkgs.flake = nixpkgs;
    nixPath = ["/etc/nix/inputs"];
  };
}
