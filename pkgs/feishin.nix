{pkgs, ...}: {
  # The nixpkgs version is about 5 months old, so we override feishin to a newer version.
  environment.systemPackages = with pkgs; [
    (feishin.overrideAttrs (_: rec {
      version = "0.20.1";
      src = fetchFromGitHub {
        owner = "jeffvli";
        repo = "feishin";
        rev = "v${version}";
        hash = "sha256-WJMaLMrv6LSw/wxn7EZOSYqwAlgW3UkeYvxV4vEkCfM=";
      };
    }))
  ];
}
