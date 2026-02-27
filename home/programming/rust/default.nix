{
  lib,
  pkgs,
  config,
  ...
}:
# Rust
{
  home.packages = with pkgs; [
    rustc # The Rust Compiler
    cargo # Rust package manager
    clippy # Rust linter
    rust-analyzer # Language server for the Rust language
  ];

  # Add a directory to PATH
  home.sessionPath = ["${config.home.homeDirectory}/.cargo/bin"];
}
