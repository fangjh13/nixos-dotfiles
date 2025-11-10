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
    cargo # rust package manager
  ];

  # Add a directory to PATH
  home.sessionPath = ["${config.home.homeDirectory}/.cargo/bin"];
}
