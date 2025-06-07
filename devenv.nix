{
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (inputs.atrolib.lib) listScripts writeShellScript;
  inherit (inputs.atrolib.lib.devenv.scripts) help runDocs buildDocs;
in {
  devenv.warnOnNewVersion = false;
  packages = [
    inputs.colmena.packages.${pkgs.system}.colmena
  ];

  languages.nix = {
    enable = true;
    lsp.package = pkgs.nil;
  };

  git-hooks.hooks = {
    inherit (inputs.atrolib.lib.devenv.git-hooks.hooks) gitleaks markdownlint;
    deadnix.enable = true;
    alejandra.enable = true;
    shellcheck.enable = true;
    lint = {
      enable = true;
      package = pkgs.statix;
      entry = "lint";
      pass_filenames = false;
    };
  };

  scripts = {
    help = help config.scripts;
    run-docs = runDocs "docs";
    build-docs = buildDocs "docs";

    lint = {
      exec = writeShellScript "lint" ''
        ${pkgs.coreutils}/bin/rm -rf "$DEVENV_ROOT/result"
        ${pkgs.statix}/bin/statix check
      '';
      description = "Lint the configuration";
    };

    apply-local = {
      exec = writeShellScript "apply-local" ''
        build && sudo nixos-rebuild switch --fast --flake .#$(hostname) || exit 1
      '';
      description = "Rebuild the system";
    };

    build = {
      exec = writeShellScript "build" ''
        sudo ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.$(hostname).config.system.build.toplevel --fallback -L --extra-experimental-features pipe-operators
      '';
      description = "Build the system";
    };

    edit-secrets = {
      exec = writeShellScript "edit-secrets" ''
        sops secrets/secrets.yaml
      '';
      description = "Edit secrets";
    };

    update = {
      exec = writeShellScript "update" ''
        sudo nix-channel --update && nix flake update && git add . && git commit -m "Update flake.lock" && apply-local
      '';
      description = "Update the system";
    };

    colmena-apply = {
      exec = writeShellScript "colmena-apply" ''
        sudo colmena apply --on "$@" --verbose
      '';
      description = "Apply the configuration using colmena to the specified hosts (e.g. 'opi*,rzr,surface')";
    };

    build-on-apply-on = {
      exec = writeShellScript "build-on-apply-on" ''
        sudo nixos-rebuild --flake ".#$2" --target-host "$2" --verbose --build-host "$1" switch
      '';
      description = "Builds configuration on $/1 and applies it on $/2";
    };

    nx-diff = {
      exec = writeShellScript "nx-diff" ''
        echo -e "---------- Building... ----------\n"
        build
        echo -e "---------- Build finished. Computing diff... ---------- \n\n\n"
        nvd diff /run/current-system result
      '';
      description = "Diff the current system with current configuration files";
    };

    render-topology = {
      exec = writeShellScript "render-topology" ''
        nix build .#topology.x86_64-linux.config.output
      '';
      description = "Render the topology image";
    };
  };

  enterTest = ''
    nix flake check
  '';

  enterShell = listScripts config.scripts;
}
