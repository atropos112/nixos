{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  defaultKeyPath = "/root/.ssh/id_ed25519";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    ssh-to-age
    age
    sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # WARN: This is the default path, it might be overwritten.
    # It does in impermanence for example.
    #
    # IMPORTANT: Ensure this SSH key exists before deploying!
    # If the key doesn't exist, SOPS will fail to decrypt secrets with an error like:
    # "no key could be found to decrypt the SOPS file"
    #
    # To check if the key exists: ls -l /root/.ssh/id_ed25519
    # To create a new key: ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""
    age.sshKeyPaths = lib.mkDefault [defaultKeyPath];
  };

  # Add a systemd service to validate SOPS keys at boot
  systemd.services.sops-key-check = {
    description = "Validate SOPS age SSH keys exist";
    wantedBy = ["multi-user.target"];
    before = ["sops-nix.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      missing_keys=()
      ${lib.concatMapStringsSep "\n" (keyPath: ''
          if [ ! -f "${keyPath}" ]; then
            echo "WARNING: SOPS age SSH key not found: ${keyPath}"
            missing_keys+=("${keyPath}")
          else
            echo "Found SOPS age SSH key: ${keyPath}"
          fi
        '')
        config.sops.age.sshKeyPaths}

      if [ ''${#missing_keys[@]} -gt 0 ]; then
        echo ""
        echo "================================================================"
        echo "ERROR: Missing SOPS age SSH keys"
        echo "================================================================"
        echo ""
        echo "The following SSH keys required for SOPS decryption were not found:"
        for key in "''${missing_keys[@]}"; do
          echo "  - $key"
        done
        echo ""
        echo "SOPS will fail to decrypt secrets without these keys!"
        echo ""
        echo "To fix this issue:"
        echo "  1. Check if keys exist elsewhere: find /root/.ssh -name 'id_*'"
        echo "  2. Update sops.age.sshKeyPaths to point to existing keys"
        echo "  3. Or generate new keys: ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519"
        echo ""
        echo "If using impermanence, ensure SSH keys are in /persistent"
        echo "================================================================"
        exit 1
      fi

      echo "All SOPS age SSH keys found successfully"
    '';
  };
}
