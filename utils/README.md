# Utils

These files should not be imported via

```nix
imports = [
    ...
]
```

as they are not real nixos configurations they are used to create other configurations.
A typical usage would be something like

```nix
autoImport = import ./utils/autoImport.nix;
```

and then using that to do normal nixos configuration stuff.
