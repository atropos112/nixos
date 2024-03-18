{
  fetchFromGitHub,
  linuxManualConfig,
  ubootTools,
  ...
}:
(linuxManualConfig {
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "linux-rockchip";
    rev = "f3fb30ac9de06b41fb621d17bc53603f1f48ac90";
    hash = "sha256-tVu/3SF/+s+Z6ytKvuY+ZwqsXUlm40yOZ/O5kfNfUYc=";
  };
  version = "6.1.43";
  modDirVersion = "6.1.43";
  extraMeta.branch = "6.1";
  configfile = ./armbian61.config;
  # configfile = ./linux-6.1.43-xunlong-rk35xx.config;
  allowImportFromDerivation = true;
})
.overrideAttrs (old: {
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
