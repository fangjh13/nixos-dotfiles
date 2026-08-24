{
  lib,
  inputs,
  hostContext,
  ...
}: let
  inherit (hostContext.settings) useGUI;
  sourceFor = import ../../lib/catppuccin-source.nix {inherit inputs;};
in {
  # Catppuccin global config (NixOS level)
  catppuccin = {
    enable = true;
    autoEnable = useGUI;
    flavor = "mocha";
    accent = "mauve";
    sources.palette = sourceFor "palette";
  };
}
