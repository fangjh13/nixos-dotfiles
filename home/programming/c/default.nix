{
  lib,
  pkgs,
  ...
}:
# C/C++ Languages
{
  home.packages = with pkgs; [
    gcc
    gdb
    cmake
    gnumake
    checkmake
    pkg-config
  ];
}
