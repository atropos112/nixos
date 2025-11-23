{
  inputs,
  config,
  ...
}: let
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

  sops.secrets.nixAccessTokens = {
    mode = "0440";
    owner = config.users.users.atropos.name;
  };

  # Basic Nix configuration
  nixpkgs.config = nixpkgs-config;
  nix = {
    # INFO: In order to not expose my access-tokens publicly, I load them from SOPS-encrypted file.
    # And to load that into nix.conf i use include directive, and because sops might come after nix setup,
    # I use the '!' to ignore errors if the file is not found. Got this idea from
    # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
    # If you want to have access-token per file or more of a split you can use extra-access-tokens too,
    # the idea is also explained in the link above.
    extraOptions = ''
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';
    settings = {
      download-buffer-size = 524288000;
      log-lines = 25; # The default 10 is too little.
      # download-buffer-size = 1024 * 1024 * 1024; # 1024 MiB, default is 64 MiB
      connect-timeout = 5; # Fallback quickly if substituters are not available.
      trusted-users = ["root" "atropos"];
      http-connections = 128; # The maximum number of parallel TCP connections used to fetch files from binary caches and by other downloads
      max-substitution-jobs = 128; # This option defines the maximum number of substitution jobs that Nix will try to run in parallel.
      auto-optimise-store = true;
      fallback = true;
      substituters = [
        "http://atticd./atro?priority=1" # My attic server
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
