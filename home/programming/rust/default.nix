{
  lib,
  pkgs,
  config,
  ...
}:
# Rust
{
  home.packages = with pkgs; [
    rustc
    cargo # Rust package manager
    clippy # Rust linter
  ];

  # Add a directory to PATH
  home.sessionPath = ["${config.home.homeDirectory}/.cargo/bin"];
}
