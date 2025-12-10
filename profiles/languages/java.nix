{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LSP
    java-language-server

    # Build tools
    maven
    gradle

    # JDKs
    javaPackages.compiler.openjdk25

    # Formatters
    google-java-format
  ];
}
