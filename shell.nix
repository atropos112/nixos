{pkgs}: let
  testy = pkgs.writeShellScriptBin "testy" ''
    echo hi
  '';
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      git
    ];
    packages = [
      pkgs.bashInteractive
      testy
    ];

    shellHook = ''
      echo "Welcome to the development environment!!!"
    '';
  }
