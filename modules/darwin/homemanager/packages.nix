{pkgs}:
with pkgs; let
  publicPkgs = import ../../public/homemanager/packages.nix {inherit pkgs;};
in
  publicPkgs
  ++ [
    # Tool for managing dock items
    dockutil
    # ip command tool for macOS
    iproute2mac
  ]
