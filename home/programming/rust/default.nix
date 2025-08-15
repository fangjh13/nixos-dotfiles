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
}
