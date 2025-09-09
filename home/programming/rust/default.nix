{
  lib,
  pkgs,
  ...
}:
# Rust
{
  home.packages = with pkgs; [
    rustc
    cargo # rust package manager
  ];

  # Add a directory to PATH
  home.sessionPath = ["$HOME/.cargo/bin"];
}
