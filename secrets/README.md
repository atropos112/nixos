# Convert SSH ED25519 Private Key To Age Secret Key
This will generate a file `keys.txt` with `AGE-SECRET-KEY-....` this is all you need to be able to call `sops secrets/secrets.yaml` from root dir of this repo.
```bash
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```

# Convert SSH ED25519 Public Key to Age Public Key
Assuming your SSH public key is in `~/.ssh/id_ed25519.pub` then its just

```bash
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```

Add that to `.sops.yaml` from device where the key is already registered. My understanding is that the secret has to be re-created (go onto it copy all of it then create new).
