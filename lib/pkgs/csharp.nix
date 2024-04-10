{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # csharp lsp
    csharp-ls

    # Dotnet SDK
    dotnet-sdk_8
    dotnet-sdk_7
    dotnet-sdk # this is 6

    # Dotnet runtime
    dotnet-runtime_8
    dotnet-runtime_7
    dotnet-runtime # this is 6
  ];
}
