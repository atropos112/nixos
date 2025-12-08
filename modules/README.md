# What is a module?

A module in this directory is:

- A single nixos module.
- Is abstract enough to be used by other people.
- Is not in itself a full implementation of a thing.

In simple terms, it should create a generic interface for an implementation to use.
Very often it is a response to a nixos/home-manager module that is missing but otherwise
fulfills the same idea.

It is ok for module to use pkg from the pkgs directory but by the bullet points above,
it can't be a bundle of pkgs and not an implementation of its own and hence
can't be a profile.

The flow is as follows:

pkgs -> Modules -> Profiles

In general if you have something that has only one way to be cofnigured then its a pkg if its one
application otherwise its a profile.

If you have more than one way to configure it then if:

- each configuration is vastly different then its profiles.
- each configuration is different but in similar way
    - if the differences can be easily configured on "client" side then its a (partial) profile
    - if they can't be easily configured on "client" side then its a module.
    - if differences are trivial then its a (partial) profile or a pkg.
