{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # csharp lsp
    csharp-ls
    csharpier
    omnisharp-roslyn

    # Dotnet SDK
    dotnet-sdk

    # Dotnet runtime
    dotnet-runtime

    netcoredbg
  ];
}
