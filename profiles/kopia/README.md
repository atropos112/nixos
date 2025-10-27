# Kopia

Kopia is my backup tool of choice.

Plan is to have all non-server devices use it and server that has images and other important data.

## Desktop devices

On both desktop devices I have impermanence so only dir I have to backup is `/persistent/`, where i skip the `Sync` directory which is synchronised via longhorn already (its in `syncthing` pvc).

To back it up I created a module that accepts `path` to instruct which path to backup, it will backup every 6 hours with compression set and all the secrets set.

## Server

On server I backup `/mnt/photos` only. Might backup more in the future.
