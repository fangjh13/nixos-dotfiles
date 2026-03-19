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
    rust-analyzer # Language server for the Rust language
    clippy # Rust linter
    rustfmt # Rust code formatter
  ];

  # Add a directory to PATH
  home.sessionPath = ["${config.home.homeDirectory}/.cargo/bin"];
}
