alias r := reload-local
alias u := update-local
alias a := apply
alias d := diff
alias s := edit-secrets

# Edit secrets
edit-secrets:
  sops secrets/secrets.yaml

# Reload the system configuration
reload-local:
  sudo nixos-rebuild switch

# Update the system configuration
update-local:
  sudo nix-channel --update && nix flake update && git add . && git commit -m "Update" --no-verify && sudo nixos-rebuild switch --upgrade-all

# Apply the system configuration without rebuilding it
apply-local msg:
  git add . && git commit -m "{{msg}}" && just reload-local && rm -f ~/.cache/tofi-drun

apply machines:
  sudo colmena apply --on "{{machines}}" --verbose

build-on-apply-on build-on apply-on:
  sudo nixos-rebuild --flake .#{{apply-on}} --target-host {{apply-on}} --verbose --build-host {{build-on}} switch

diff:
  sudo nixos-rebuild build  && nvd diff /run/current-system result
