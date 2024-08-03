{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rustup # CLI tool for managing Rust stuff
    rust-analyzer # LSP server for Rust
    vscode-extensions.vadimcn.vscode-lldb # Debugger for Rust
    cargo # Rust package manager
  ];
}
