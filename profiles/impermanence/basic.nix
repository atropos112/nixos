_: {
  atro.impermanence = {
    enable = true;
    userName = "atropos";
    global = {
      dirs = [
        "/root/.ssh" # Root SSH keys (used during age key decryption)
        "/var/lib/tailscale" # Tailscale login state. Tried doing ephemeral, comes with bunch of issues...
      ];
      files = [
        "/etc/machine-id" # Some apps rely on this being fixed.
      ];
    };
    home = {
      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
      dirs = [
        ".ssh" # User SSH keys
        ".local/share/zoxide" # Zoxide cache (otherwise its useless)
        ".local/share/keyrings" # GPG keys for GNOME keyring
        ".local/share/atuin" # Atuin cache

        ".cache/direnv" # Very annoying to wait each time
        ".cache/nix" # Sam as with direnv.
      ];
    };
  };
}
