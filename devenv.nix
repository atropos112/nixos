{
  pkgs,
  lib,
  config,
  ...
}: {
  packages = with pkgs; [
    nix-search-cli
    nix-output-monitor
    nix-melt
    deploy-rs
  ];

  languages.nix = {
    enable = true;
    lsp.package = pkgs.nil;
  };

  pre-commit.hooks = {
    deadnix.enable = true;
    alejandra.enable = true;
    shellcheck.enable = true;
    gitleaks = {
      enable = true;
      package = pkgs.gitleaks;
      entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose";
      pass_filenames = false;
    };
    lint = {
      enable = true;
      package = pkgs.statix;
      entry = "nx-lint";
      pass_filenames = false;
    };
  };

  scripts = {
    nx-inspect = {
      exec = ''${pkgs.nix-inspect}/bin/nix-inspect "$@" '';
      description = "Inspect the entire configuration, like a json tree";
    };
    browse-flake-lock = {
      exec = ''
        ${pkgs.nix-melt}/bin/nix-melt
      '';
      description = "Browse the flake.lock contents";
    };
    nx-deploy-single = {
      exec = ''
        set -xeu
        sudo ${pkgs.deploy-rs}/bin/deploy --remote-build --skip-checks --fast-connection=true .#$@ -- --extra-experimental-features pipe-operators --fallback
      '';
    };
    nx-deploy = {
      exec = ''
        sudo -v
        echo "$@" | ${pkgs.rush-parallel}/bin/rush -D " " "nx-deploy-single {}"
      '';
    };
    nx-lint = {
      exec = ''
        ${pkgs.coreutils}/bin/rm -rf "$DEVENV_ROOT/result"
        ${pkgs.statix}/bin/statix check
      '';
      description = "Lint the configuration";
    };
    nx-search = {
      exec = ''
        ${pkgs.nix-search-cli}/bin/nix-search "$@"
      '';
      description = "Search for a package";
    };
    apply-local = {
      exec = ''
        nx-build && sudo nixos-rebuild switch --fast --flake .#$(hostname) || exit 1
      '';
      description = "Rebuild the system";
    };
    nx-build = {
      exec = ''
        sudo ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.$(hostname).config.system.build.toplevel -L --extra-experimental-features pipe-operators
      '';
      description = "Build the system";
    };
    edit-secrets = {
      exec = ''
        sops secrets/secrets.yaml
      '';
      description = "Edit secrets";
    };
    nx-update = {
      exec = ''
        sudo nix-channel --update && nix flake update && git add . && git commit -m "Update flake.lock" && apply-local
      '';
      description = "Update the system";
    };
    colmena-apply = {
      exec = ''
        sudo colmena apply --on "$@" --verbose
      '';
      description = "Apply the configuration using colmena to the specified hosts (e.g. 'opi*,rzr,surface')";
    };
    colmena-apply-k8s = {
      exec = ''
        colmena-apply "opi1,opi2,opi3,opi4,rzr,smol,a21"
      '';
      description = "Apply the configuration using colmena to all Kubernetes nodes.";
    };
    build-on-apply-on = {
      exec = ''
        sudo nixos-rebuild --flake ".#$2" --target-host "$2" --verbose --build-host "$1" switch
      '';
      description = "Builds configuration on $/1 and applies it on $/2";
    };
    nx-diff = {
      exec = ''
        echo -e "---------- Building... ----------\n" && nx-build && echo -e "---------- Build finished. Computing diff... ---------- \n\n\n" && nvd diff /run/current-system result
      '';
      description = "Diff the current system with current configuration files";
    };
    help = {
      exec = ''
        echo
        echo 🦾 Useful project scripts:
        echo 🦾
        ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
        ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
        EOF
        echo
      '';
      description = "Show this help message";
    };
  };

  enterTest = ''
    nix flake check
  '';

  enterShell = ''
    echo
    echo 🦾 Useful project scripts:
    echo 🦾
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
    EOF
    echo

  '';
}
