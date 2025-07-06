# What is a pkg?

A pkg in this directory is

- A single nixpkgs package with some configuration
- Does not utilised any of my modules module (that would be a profile)
- Has a config that would apply anywhere in my stack where the application makes
  sense to run. That is, a pkg is independent of the system it is on.

The flow is as follows:

Pkgs -> Modules -> Profiles
