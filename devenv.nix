{
  pkgs,
  lib,
  config,
  ...
}: {
  packages = with pkgs; [
    nix-search-cli
    nix-melt
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
    statix = {
      enable = true;
      package = pkgs.statix;
      entry = "${pkgs.statix}/bin/statix check";
      pass_filenames = false;
    };
  };

  scripts = {
    browse-flake-lock = {
      exec = ''
        ${pkgs.nix-melt}/bin/nix-melt
      '';
      description = "Browse the flake.lock contents";
    };
    search = {
      exec = ''
        ${pkgs.nix-search-cli}/bin/nix-search "$@"
      '';
      description = "Search for a package";
    };
    rebuild = {
      exec = ''
        sudo nixos-rebuild switch
      '';
      description = "Rebuild the system";
    };
    edit-secrets = {
      exec = ''
        sops secrets/secrets.yaml
      '';
      description = "Edit secrets";
    };
    update = {
      exec = ''
        sudo nix-channel --update && nix flake update && git add . && git commit -m "Update flake.lock" && sudo nixos-rubuild switch --upgrade-all
      '';
      description = "Update the system";
    };
    apply = {
      exec = ''
        sudo colmena apply --on "$@" --verbose
      '';
      description = "Apply the configuration using colmena";
    };
    build-on-apply-on = {
      exec = ''
        sudo nixos-rebuild --flake ".#$2" --target-host "$2" --verbose --build-host "$1" switch
      '';
      description = "Builds configuration on $/1 and applies it on $/2";
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
