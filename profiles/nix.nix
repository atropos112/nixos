{inputs, ...}: let
  nixpkgs = inputs.nixpkgs-unstable;
  nixpkgs-config = {
    allowUnfree = true;
    allowBroken = false;
  };
in {
  home-manager.users.atropos.nixpkgs.config = nixpkgs-config;
  home-manager.users.root.nixpkgs.config = nixpkgs-config;

  # We do not want user user configurations to mess with our global settings.
  system.activationScripts.clearusernixconf = ''
    rm -rf /home/atropos/.config/nix
    rm -rf /root/.config/nix
  '';

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
        "http://atticd./atro" # My attic server
        "https://hyprland.cachix.org" # Hyprland Cachix server
        "https://nix-community.cachix.org" # Nix community Cachix server
        "https://devenv.cachix.org" # Devenv Cachix server
        "https://nixpkgs-python.cachix.org" # Python Cachix server
        "https://statix.cachix.org" # Statix Cachix server
        "https://cuda-maintainers.cachix.org" # CUDA Cachix server
        "https://pre-commit-hooks.cachix.org" # pre-commit-hooks Cachix server
      ];
      trusted-public-keys = [
        "atro:IKE2rH/UrLj0OJRhL2MLWSiTMaQjZ+j4eukVpulaLm8=" # My attic server
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Hyprland Cachix server
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # Nix community Cachix server
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" # Devenv Cachix server
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=" # Python Cachix server
        "statix.cachix.org-1:Z9E/g1YjCjU117QOOt07OjhljCoRZddiAm4VVESvais=" # Statix Cachix server
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" # CUDA Cachix server
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc=" # pre-commit-hooks Cachix server
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
