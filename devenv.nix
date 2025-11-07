{
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (inputs.atrolib.lib) listScripts writeShellScript;
  inherit (inputs.atrolib.lib.devenv.scripts) help;
in {
  devenv.warnOnNewVersion = false;

  languages.nix = {
    enable = true;
    lsp.package = inputs.nil_ls.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nil;
  };

  packages = with pkgs; [
    nix-output-monitor
  ];

  git-hooks.hooks = {
    inherit (inputs.atrolib.lib.devenv.git-hooks.hooks) gitleaks markdownlint;
    deadnix.enable = true;
    alejandra.enable = true;
    shellcheck.enable = true;
    lint = {
      enable = false; # TODO: https://github.com/oppiliappan/statix/issues/139 needs to be resolved first.
      package = inputs.statix.packages.${pkgs.stdenv.hostPlatform.system}.statix;
      entry = "lint";
      pass_filenames = false;
    };
  };

  scripts = {
    help = help config.scripts;

    lint = {
      exec = writeShellScript "lint" ''
        ${pkgs.coreutils}/bin/rm -rf "$DEVENV_ROOT/result"
        ${pkgs.statix}/bin/statix check
      '';
      description = "Lint the configuration";
    };

    apply-local = {
      exec = writeShellScript "apply-local" ''
        build "$@" && sudo nixos-rebuild switch --no-reexec --flake .#$(hostname) || exit 1
      '';
      description = "Rebuild the system";
    };

    build = {
      exec = writeShellScript "build" ''
        sudo ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.$(hostname).config.system.build.toplevel --fallback -L "$@"
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

    colmena-apply-servers = {
      exec = writeShellScript "colmena-apply-servers" ''colmena-apply "rzr,a21,smol,opi*,orth"'';
      description = "Apply the configuration using colmena to all servers";
    };

    build-on-apply-on = {
      exec = writeShellScript "build-on-apply-on" ''
        sudo nixos-rebuild --flake ".#$2" --target-host "$2" --verbose --build-host "$1" switch
      '';
      description = "Builds configuration on $/1 and applies it on $/2";
    };

    nx-diff = {
      exec = writeShellScript "nx-diff" ''
        build
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

    nix-to-json = {
      # I am 100% committing a nix crime here, embedding nix inside of bash inside of nix
      # not sure how to make it better though :(
      exec = writeShellScript "nix-to-json" ''
        # Get Nix input
        if [ $# -eq 1 ]; then
            if [ -f "$1" ]; then
                nix_input=$(cat "$1")
            else
                nix_input="$1"
            fi
        elif [ $# -eq 0 ]; then
            nix_input=$(cat)
        else
            echo "Usage: $0 [NIX_EXPRESSION|FILE]" >&2
            exit 1
        fi

        # Use nix-instantiate to evaluate and convert to JSON
        # Load the flake from /home/atropos/nixos/flake.nix for config access
        nix eval --impure --json --expr  "
        let
          flake = builtins.getFlake \"/home/atropos/nixos\";
          # Try to get the first nixos configuration available
          configName = builtins.head (builtins.attrNames flake.nixosConfigurations);
          config = flake.nixosConfigurations.\''${configName}.config;
          pkgs = import <nixpkgs> {};
          lib = pkgs.lib;
        in
        $nix_input
        " | jq .
      '';
      description = "Transforms nix to json with my nixos flake pre-imported.";
    };

    nix-to-json-simple = {
      exec = writeShellScript "nix-to-json-simple" ''
        # Get Nix input
        if [ $# -eq 1 ]; then
            if [ -f "$1" ]; then
                nix_input=$(cat "$1")
            else
                nix_input="$1"
            fi
        elif [ $# -eq 0 ]; then
            nix_input=$(cat)
        else
            echo "Usage: $0 [NIX_EXPRESSION|FILE]" >&2
            exit 1
        fi

        # Use nix-instantiate to evaluate and convert to JSON
        nix-instantiate --eval --strict --json --expr "$nix_input" | jq .
      '';
      description = "Transforms nix to json, simple, no pre-imports.";
    };

    json-to-nix = {
      description = "Transforms JSON to Nix expression";
      # I am 100% committing a nix crime here, embedding nix inside of bash inside of nix
      # not sure how to make it better though :(
      exec = writeShellScript "json-to-nix" ''

        # Get JSON input
        if [ $# -eq 1 ]; then
            # For passing in directly
            json_input="$1"
        elif [ $# -eq 0 ]; then
            # For piping
            json_input=$(cat)
        else
            echo "Usage: $0 [JSON_STRING]" >&2
            exit 1
        fi

        # Validate JSON
        if ! echo "$json_input" | jq empty 2>/dev/null; then
            echo "Error: Invalid JSON input" >&2
            exit 1
        fi

        # Escape for Nix string literal
        escaped_json=$(echo "$json_input" | sed "s/\\\\/\\\\\\\\/g; s/'/\\\\'/g")

        # Use nix-instantiate to evaluate and print the result
        nix-instantiate --eval --strict --expr "
        let
          json = ''' ''${escaped_json} ''';
          nixValue = builtins.fromJSON json;
        in
        nixValue
        "
      '';
    };
  };

  enterTest = ''
    nix flake check
  '';

  enterShell = listScripts config.scripts;
}
