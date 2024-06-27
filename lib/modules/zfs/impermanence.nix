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

      mkdir -p /persistent/home/atropos
      HOME_OWNER=$(stat -c '%u' "/persistent/home/atropos") # Optimising, only chown if the whole dir is not belonging to the user.
      if [ "$HOME_OWNER" -ne "1000" ]; then
       echo "Fixing permissions for persistent..."
       chown -R 1000:1000 /persistent/home/atropos
      fi

      echo "Unmounting home..."
      umount /home

      echo "Unmounting persistent..."
      umount /persistent

      echo "Permissions fixed."
      echo "--------------------------------------------------"
    '';

    sops.age.sshKeyPaths = lib.mkForce ["/persistent/root/.ssh/id_ed25519"];

    environment.persistence."/persistent" = {
      hideMounts = true;
      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
      users.atropos = {
        directories = [
          ".ssh" # User SSH keys
          ".wakatime" # Wakatime downloads some cache (some bins etc)
          "Sync" # Syncthing
          "projects" # Code projects
          "nixos" # NixOS config

          ".config/vivaldi" # Vivaldi browser content (config, cache, open pages, etc.)
          ".config/nvim" # Neovim config
          ".config/Element" # Element desktop config.
          ".config/github-copilot"
          ".config/sops/age" # Allowing atropos user read and edit the age keys
          ".config/wakatime" # waka time local bin's otherwise it wipes the password. There is a WAKATIME_HOME environment variable pointing to this dir.

          ".local/share/nvim" # Neovim plugins and basic cache (Treesitter, etc.)
          ".local/share/zoxide" # Zoxide cache (otherwise its useless)
          ".local/share/keyrings" # GPG keys for GNOME keyring
          ".local/share/atuin" # Atuin cache TODO: Check if this is necessary

          ".kube" # Kubernetes config (for kubectl) # TODO: Set variable to map to /persistent's kubeconfig via KUBECONFIG=...

          ".cache/direnv" # Very annoying to wait each time
        ];
      };
      directories = [
        "/root/.ssh" # Root SSH keys (used during age key decryption)
        "/var/lib/bluetooth" # Keep track of bluetooth devices
        "/var/lib/tailscale" # Tailscale login state. Tried doing ephemeral, comes with bunch of issues...
      ];
      # INFO: These dirs are not relative, must be full path.
      files = [
        "/etc/machine-id" # Some apps rely on this being fixed.
      ];
    };
  };
}
