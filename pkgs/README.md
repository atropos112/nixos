# What is a pkg?

A pkg is a nixpkgs package with a configuration.
Only one package per file.

Read profiles README.md as the line between pkgs and profiles is somewhat
blurry and arbitrary.

In simple terms, a pkg here is an application with a configuration that is
independent of the system I am on. A profile on the other hand is tailored
to the system, usecase or can simply be a "bundle" of packages for a usecase.

If we left it there then you could easily find a loophole in my definitions
of profiles, pkgs and modules. Namely you could always make a module that
can be used by a package to give a profile-like experience. I do not like this
because it means there is two ways to do the same thing. Another rule I impose
is that a pkg should not be using a module so that we have

pkgs -> modules -> profiles

directoion only.
