{
  lib,
  pkgs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) useGUI;
in {
  # Catppuccin global config (NixOS level)
  catppuccin = {
    enable = lib.mkIf useGUI true;
    flavor = "mocha";
    accent = "mauve";
  };
}
