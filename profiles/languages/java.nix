{pkgs, ...}: {
  environment.sessionVariables = {
    JAVA_HOME = "${pkgs.openjdk21}";
  };

  environment.systemPackages = with pkgs; [
    # LSP
    jdt-language-server

    # Build tool
    gradle

    # JDK
    openjdk21

    # Formatters
    google-java-format
  ];
}
