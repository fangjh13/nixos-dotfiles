{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.profiles.desktop;
  profileReady = cfg.enable && cfg.defaultTerminal != null;
  sourceFor = import ../../lib/catppuccin-source.nix {inherit inputs;};
in {
  config = {
    # Catppuccin global config (NixOS level)
    catppuccin =
      {
        enable = profileReady;
        autoEnable = profileReady;
      }
      // lib.optionalAttrs profileReady {
        flavor = "mocha";
        accent = "mauve";
        sources.palette = sourceFor "palette";
      };
  };
}
