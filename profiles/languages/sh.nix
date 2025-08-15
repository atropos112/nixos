{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    shellcheck
    shfmt
    bash-language-server
  ];
}
