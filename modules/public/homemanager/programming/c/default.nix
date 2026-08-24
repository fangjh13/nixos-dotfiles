{
  lib,
  pkgs,
  ...
}:
# C/C++ Languages
{
  home.packages = with pkgs;
    [
      cmake
      gnumake
      checkmake
      pkg-config
      clang-tools
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      gcc
      gdb
    ];
}
