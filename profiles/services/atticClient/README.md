# Attic

Having set up a fresh attic client there is a few steps to follow to get it to be usable.
I am rehashing the content from [attic's own docs](https://docs.attic.rs/user-guide/index.html) a bit but with more detail and more personal specifics.

## Making token

First you need to make a token for the attic client to use, this token allows you to do stuff.

Only an admin of the token server can create tokens they need two parts to do so

- `config.toml` file containing contents of config the attic server uses.
- `ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64` environment variable set to the secret used to sign tokens the attic server itself uses

With the environment variable set via `export ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="..."` you can now run the command to make a token.

```bash
nix-shell -p attic-server

atticadm make-token \
    --validity "10y" \
    --sub "atro" \
    --pull "atro" \
    --push "atro" \
    --create-cache "atro" \
    --configure-cache "atro" \
    --configure-cache-retention "atro" \
    --destroy-cache "atro*" -f ./config.toml
```

> [!WARNING]
> You might think you can do "\*" instead of "atro" but that will not work, not sure why not.

Now you have a token you can use with attic client.

## Creating cache and configuring it

To create cache you must first login with the token you created earlier. Assuming you can access you attic server at `http://atticd.` you can login like so:

```bash
attic login atticd http://atticd. '<your-token-here>'
```

Here `atticd` after the login command is the name of the server in case you have multiple attic servers you want to use.

Now you can create a cache like so:

```bash
attic cache create --priority=1 atticd:atro
```

```bash
attic use atticd:atro
```

Now your user can access the cache you just created, push to it and pull from it.

> [!NOTE]
> here when doing `attic use ...` you will get public key, take note of that for later when configuring nix settings.

## Making it all decleartive

I want both my user and root to be able to use attic without having to login manually every time. I dislike the fact that attic overrides this stuff at `~/.config/nix` level as well as it enforces odd dynamics this way.
In fact I don't really need the `~/.config/attic` as I am not interacting with attic anymore, but the root user will have to when pushing with systemd service.

So here is what I did to make it work:

- Copy config that was created at `~/.config/attic/config.toml` into sops (in `attic/config`) and then make

  ```nix
  sops.secrets."attic/config" = {
      owner = "root";
      path = "/root/.config/attic/config.toml";
      mode = "0444"; # Read only
  };
  ```

- Copy the contents of file `~/.config/nix/netrc` into sops (in `attic/netrc`) and then make

  ```nix
  sops.secrets."attic/netrc" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
  };
  ```

  So that it can be accessed by `atropos` and `root` only.

- Set correct nix settings

  ```nix
  nix.settings = {
      trusted-users = ["root" "atropos"];
      http-connections = 128; # The maximum number of parallel TCP connections used to fetch files from binary caches and by other downloads
      max-substitution-jobs = 128; # This option defines the maximum number of substitution jobs that Nix will try to run in parallel.
      fallback = true;
      netrc-file = config.sops.secrets."attic/netrc".path;
      substituters = [
        "http://atticd./atro?priority=1" # My attic server
      ];
      trusted-public-keys = [
        "<public-key-from-attic-use-command-output" # My attic server
      ];
      ...
  }
  ```

## Pushing in background

At this point client will be able to use attic cache content, but we also want to push in the background.

```nix
systemd.services.attic-client = {
    description = "Attic watch store";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.attic-client}/bin/attic watch-store atticd:atro --ignore-upstream-cache-filter";
      Restart = "on-failure";
      RestartSec = "5s";
    };
};
```

Here `--ignore-upstream-cache-filter` is needed if you want to push everything no matter what filter the attic server has,
which I do because I want to rely on external stores as little as possible.

## References

- [Attic user guide](https://docs.attic.rs/user-guide/index.html)
- [Attic admin guide](https://docs.attic.rs/admin-guide/index.html)
- [TIL: how to optimise substitutions in Nix](https://bmcgee.ie/posts/2023/12/til-how-to-optimise-substitutions-in-nix/)
