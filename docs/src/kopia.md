# Kopia

Kopia is my backup tool of choice.

I have two non-server devices, my PC and my laptop.

On both of those I have impermanence so only dir I have to backup is `/persistent/`, where i skip the `Sync` directory which is synchronised via longhorn already (its in `syncthing` pvc).

To back it up I created a module that accepts `path` to instruct which path to backup, it will backup every 6 hours with compression set and all the secrets set.
