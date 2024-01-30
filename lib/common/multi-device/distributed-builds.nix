{
  config,
  pkgs,
  ...
}: let
  # defaults
  maxJobs = 2;
  speedFactor = 2;
  protocol = "ssh-ng";
  supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
  mandatoryFeatures = [];

  armSsh = [
    "ssh-ng://opi1"
    "ssh-ng://opi2"
    "ssh-ng://opi3"
    "ssh-ng://opi4"
  ];
  amdSsh = [
    "ssh-ng://rzr"
    "ssh-ng://giant"
    "ssh-ng://smol"
    "ssh-ng://a21"
  ];
  inherit (config.networking) hostName;
  shortHostName =
    if builtins.substring 0 4 hostName == "atro"
    then builtins.substring 4 (builtins.stringLength hostName) hostName
    else hostName;
in {
  nix = {
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    buildMachines = builtins.filter (ele: ele.hostName != shortHostName && ele.system == pkgs.system) [
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures;
        hostName = "rzr";
        system = "x86_64-linux";
        speedFactor = 4;
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "a21";
        system = "x86_64-linux";
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "smol";
        system = "x86_64-linux";
      }
      {
        inherit protocol supportedFeatures mandatoryFeatures;
        hostName = "giant";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 8;
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "opi1";
        system = "aarch64-linux";
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "opi2";
        system = "aarch64-linux";
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "opi3";
        system = "aarch64-linux";
      }
      {
        inherit protocol maxJobs supportedFeatures mandatoryFeatures speedFactor;
        hostName = "opi4";
        system = "aarch64-linux";
      }
    ];
    settings = {
      substituters = builtins.filter (ele: ele != "ssh-ng://${shortHostName}") (
        if pkgs.system == "x86_64-linux"
        then amdSsh
        else armSsh
      );

      # These keys are generated using `sudo nix-store --generate-binary-cache-key <NAMEOFNODEHERE> cache-priv-key.pem cache-pub-key.pem`
      # Then the public key is added to the list below, while private key is added to sops secrets file.
      trusted-public-keys = [
        "rzr:xSv3cX/KbnJQ2d/SsyZzAd1MG8bSFULL5khCQB+ENqE="
        "giant:MvuwyDBlmw2jyt/CLzXfXBqTwopvKsaBKvds0KHX/WA="
        "smol:Uh7wgv99+jtqM0tQe0aNY9a4jFwNxfmMZGlf1aAf7Dk="
        "a21:eNETxmk9y67sV4GRlFPqmp2fV91vO4lPUgtbLRmfQeE="

        "opi1:pdAh7zTEql1U53932HXg6HIO8NuEJ6K5/v+2RCA9YIM="
        "opi2:y9zthp0AVb4gjCwZ5fruFqJZg/TVxaZ0fieoqBfMyn0="
        "opi3:8HakYTEoNiUqZjOIeA5B1Tvqtgf74RUpSPvkb5MFWX0="
        "opi4:A1i5WmTXcKWyveo+7zRHpz/+qaNjayGGhhu821ajUN4="
      ];
    };
  };
}
