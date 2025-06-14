{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rustup # CLI tool for managing Rust stuff
    rust-analyzer # LSP server for Rust
    cargo # Rust package manager
    bacon
    rustfmt
    vscode-extensions.vadimcn.vscode-lldb
  ];
}
