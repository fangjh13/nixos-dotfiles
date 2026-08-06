{
  lib,
  pkgs,
  hostVars,
  ...
}: let
  inherit (hostVars) useGUI;
in {
  # Catppuccin global config (NixOS level)
  catppuccin = {
    enable = true;
    autoEnable = useGUI;
    flavor = "mocha";
    accent = "mauve";
  };
}
