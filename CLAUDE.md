# Claude Code Instructions for this Repository

## CRITICAL: Repository Sensitivity

This is a highly sensitive repository. Follow these rules strictly:

### Never Push

- **NEVER run `git push`** in this repository under any circumstances
- All commits should be reviewed by the user before pushing

### Extreme Care Required

- Double-check and triple-check all changes before making them
- Take extra time to verify correctness - speed is not a priority here
- Mistakes are not acceptable
- If unsure about anything, ask first
- Prefer smaller, incremental changes over large sweeping modifications
- Always read existing code thoroughly before suggesting modifications

### Before Making Any Change

1. Read and understand the affected files completely
2. Consider potential side effects
3. Verify the change is correct
4. Review the change after making it

### After Making Changes

1. Run `prek -a` to validate changes with pre-commit hooks (alejandra, deadnix, gitleaks, markdownlint, shellcheck, statix). If sandbox restrictions prevent this, run with sandbox disabled.
2. Fix any issues reported before considering the task complete

## Code Patterns

### Home-Manager Symlinks with mkOutOfStoreSymlink

When creating out-of-store symlinks in home-manager (e.g., for impermanence), use the NixOS-level `config` argument, NOT the home-manager function form. See `pkgs/claude.nix` for the correct pattern:

```nix
{
  config,  # NixOS config, NOT home-manager config
  ...
}: {
  home-manager.users.atropos = {
    home.file.".example".source = config.lib.file.mkOutOfStoreSymlink "/persistent/path";
  };
}
```

Do NOT use the function form `home-manager.users.atropos = {config, ...}: { ... }` unless absolutely necessary.
