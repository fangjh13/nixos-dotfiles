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
    enable = true;
    autoEnable = useGUI;
    flavor = "mocha";
    accent = "mauve";
  };
}
