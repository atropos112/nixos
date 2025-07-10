{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rust-analyzer # LSP server for Rust
    cargo # Rust package manager
    bacon
    rustc
    rustfmt
    vscode-extensions.vadimcn.vscode-lldb
  ];
}
