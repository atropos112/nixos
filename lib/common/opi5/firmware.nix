{
  fetchFromGitHub,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "orangepi-firmware";
  version = "2024.08.01";
  dontBuild = true;
  dontFixup = true;
  compressFirmware = false;

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "firmware";
    rev = "a1bdbf549ba503edd514c26367a847bc9d83dd4a";
    hash = "sha256-RvVWq40++0VPNGQYu5PKDNZr1oZ/n4jf9majl27jO/c=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware
    cp -a * $out/lib/firmware/

    runHook postInstall
  '';
}
