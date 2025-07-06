# What is a profile?

A profile is either

- An implementation of a module from `modules` directory
- A union of packages from `pkgs` directory or `nixpkgs` itself if
  no configuration is needed.
- A union of profiles (closed under composition)

It is a convinience "bundle" of things that are expected to be used together by
more than one system.

When implementing a bundle the expectation is that the path
in `profiles` is matching that of `modules` as close as possible.

A bit of an arbitrary separation between this and packages is that a profile
is likely not going to be selected for every usecase of mine, its a "selection".
Where as a package implementation is a "this is THE config" for me and will
definitely be selected for every usecase and be the same.

This distinction is an arbitrary one in a way, I needed to draw a line somewhere
and this is the line, I like this line, I don't feel strongly about this line.
