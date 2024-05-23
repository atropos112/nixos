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

      # Check and destroy the 'previous' snapshot if it exists for root
      if zfs list -t snapshot | grep -q 'zroot/nixos/root@previous'; then
          echo "Destroying previous snapshot for root"
          zfs destroy zroot/nixos/root@previous
      fi

      # Check and rename the 'current' snapshot to 'previous' if it exists for root
      if zfs list -t snapshot | grep -q 'zroot/nixos/root@current'; then
          echo "Renaming current snapshot for root to previous"
          zfs rename zroot/nixos/root@current zroot/nixos/root@previous
      fi

      # Create a new 'current' snapshot for root
      echo "Creating new current snapshot for root"
      zfs snapshot zroot/nixos/root@current

      # Rollback to 'blank' for root
      echo "Rolling back to blank for root"
      zfs rollback -r zroot/nixos/root@blank

      # Check and destroy the 'previous' snapshot if it exists for home
      if zfs list -t snapshot | grep -q 'zroot/nixos/home@previous'; then
          echo "Destroying previous snapshot for home"
          zfs destroy zroot/nixos/home@previous
      fi

      # Check and rename the 'current' snapshot to 'previous' if it exists for home
      if zfs list -t snapshot | grep -q 'zroot/nixos/home@current'; then
          echo "Renaming current snapshot for home to previous"
          zfs rename zroot/nixos/home@current zroot/nixos/home@previous
      fi

      # Create a new 'current' snapshot for home
      echo "Creating new current snapshot for home"
      zfs snapshot zroot/nixos/home@current

      # Rollback to 'blank' for home
      echo "Rolling back to blank for home"
      zfs rollback -r zroot/nixos/home@blank

      # Mounting home to fix permissions
      echo "Mounting home and persistent to fix permissions"
      mkdir -p /home
      mount -t zfs zroot/nixos/home /home

      mkdir -p /persistent
      mount -t zfs zroot/nixos/persistent /persistent

      # Fixing permissions for home and root home and persistent
      echo "Fixing permissions for home"
      mkdir -p /home/atropos/.config /home/atropos/.local /home/atropos/.cache /home/atropos/.ssh /home/atropos/Sync /home/atropos/.local/share
      chown -R 1000:1000 /home/atropos

      mkdir -p /persistent/home/atropos
      chown -R 1000:1000 /persistent/home/atropos

      # Unmounting
      echo "Unmounting home and persistent"
      umount /home
      umount /persistent

      echo "Impermanence setup complete."
      echo "--------------------------------------------------"
    '';

    environment.persistence."/persistent" = {
      hideMounts = true;
      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
      users.atropos = {
        directories = [
          ".ssh"
          "Sync"
          "projects"
          "nixos"
          ".config/vivaldi"
          ".config/nvim"
          ".local/share/nvim"
          ".local/share/zoxide"
        ];
        files = [
          ".zsh_history"
        ];
      };
      directories = [
        # TODO: Figure out a way to generate this.
        "/etc/NetworkManager/system-connections" # To store wifi passwords/connections
        "/root/.ssh"
      ];
      # INFO: These dirs are not relative, must be full path.
      files = [
        "/var/lib/tailscale/tailscaled.state"
      ];
    };
  };
}
