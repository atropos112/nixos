{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.atro.hardware.zfs.impermanence;
in {
  options.atro.hardware.zfs.impermanence = {
    enable = mkEnableOption "zfs with impermanence";
  };

  config = mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      echo "--------------------------------------------------"
      echo "Setting up impermanence..."

      echo "Rolling root back to blank..."
      zfs rollback -r zroot/nixos/root@blank

      echo "Rolling home back to blank..."
      zfs rollback -r zroot/nixos/home@blank

      echo "Impermanence setup complete."
      echo "--------------------------------------------------"
      echo "Fixing permissions..."

      echo "Mounting home..."
      mkdir -p /home
      mount -t zfs zroot/nixos/home /home

      echo "Mounting persistent..."
      mkdir -p /persistent
      mount -t zfs zroot/nixos/persistent /persistent

      echo "Fixing permissions for home..."
      mkdir -p /home/atropos/.config /home/atropos/.local /home/atropos/.cache /home/atropos/.ssh /home/atropos/Sync /home/atropos/.local/share
      chown -R 1000:1000 /home/atropos

      echo "Fixing permissions for persistent..."
      mkdir -p /persistent/home/atropos
      chown -R 1000:1000 /persistent/home/atropos

      echo "Unmounting home..."
      umount /home

      echo "Unmounting persistent..."
      umount /persistent

      echo "Permissions fixed."
      echo "--------------------------------------------------"
    '';

    environment.persistence."/persistent" = {
      hideMounts = true;
      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
      users.atropos = {
        directories = [
          ".ssh" # User SSH keys
          "Sync" # Syncthing
          "projects" # Code projects
          "nixos" # NixOS config

          ".config/vivaldi" # Vivaldi browser content (config, cache, open pages, etc.)
          ".config/nvim" # Neovim config

          ".local/share/nvim" # Neovim plugins and basic cache (Treesitter, etc.)
          ".local/share/zoxide" # Zoxide cache (otherwise its useless)
          ".local/share/keyrings" # GPG keys for GNOME keyring
          ".local/share/atuin" # Atuin cache TODO: Check if this is necessary
        ];
        files = [
          ".zsh_history" # Zsh history, likely to be superseded by atuin soon
          ".kube/config" # Kubernetes config (for kubectl)
          ".config/sops/age/keys.txt" # Allowing atropos user read and edit the age keys
        ];
      };
      directories = [
        "/root/.ssh" # Root SSH keys (used during age key decryption)
        "/var/lib/bluetoth" # Keep track of bluetooth devices
      ];
      # INFO: These dirs are not relative, must be full path.
      files = [
        "/var/lib/tailscale/tailscaled.state" # Tailscale login state. Tried doing ephemeral, comes with bunch of issues...
      ];
    };
  };
}
