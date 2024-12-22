{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    (python312.withPackages (ps: with ps; [pandas numpy]))

    ruff
    poetry
    uv # pip but faster.
  ];
}
