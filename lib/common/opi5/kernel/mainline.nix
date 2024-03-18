{
  fetchFromGitHub,
  linuxManualConfig,
  ubootTools,
  ...
}:
(linuxManualConfig {
  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    rev = "f6cef5f8c37f58a3bc95b3754c3ae98e086631ca";
    hash = "sha256-tVu/3SF/+s+Z6ytKvuY+ZwqsXUlm40yOZ/O5kfNfUYc=";
  };
  version = "6.8.0";
  modDirVersion = "6.8.0";
  extraMeta.branch = "6.8";
  # configfile = ./linux-6.1.43-xunlong-rk35xx.config;
  allowImportFromDerivation = true;
})
.overrideAttrs (old: {
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
