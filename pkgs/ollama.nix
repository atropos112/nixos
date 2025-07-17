{pkgs, ...}: let
  # Ollama has this check that ensures you have enough available memory to run the model.
  # However it sees ZFS ARC as something memory that is not available even though it is.
  # The issue has been open since 2024-07-15 (more than a year)
  # https://github.com/ollama/ollama/issues/5700
  # And yet for some reason they decided for the check to stay and ZFS people screw you basically
  # So I forked it and removed that stupid check.
  customOllama = pkgs.ollama-cuda.overrideAttrs (_: {
    src = pkgs.fetchFromGitHub {
      owner = "atropos112";
      repo = "ollama";
      rev = "47505f66cb9391f589ef12ce868938d0dd9c48ea"; # Specific commit hash
      hash = "sha256-C5IdGxTeo6SXSUA4AeVtGSlSG5FfYuf/MTZWDNzR1rs=";
      fetchSubmodules = true;
    };
  });
in {
  services.ollama = {
    package = customOllama;
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    acceleration = "cuda";
  };

  environment.systemPackages = [
    customOllama
  ];
}
