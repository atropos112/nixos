# Atro NixOS Setup

The following are a work in progress:
- Documentation is lacking in general, it should have way more comments, way more readme's and ideally (time permitting) some guides how it was done
- Nixvim setup (learining to be a vim man at the same time so this may take a while)
- Orange Pi Zero 2W setup is not working, I was able to create the sd-image but current kernel support is not there so can't test if I did it correctly.
- SSH keys are provided in `lib/common/default.nix` and in `lib/modules/zfs-root` in variety of ways, I would like this all unified.
- `lib/common/desktop/default.nix` has stuff it shouldn't have, cilium for example.
