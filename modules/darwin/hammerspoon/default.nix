{
  config,
  lib,
  hostContext,
  ...
}: let
  inherit (hostContext) username;
  cfg = config.addon.hammerspoon;
in {
  options.addon.hammerspoon.enable =
    lib.mkEnableOption "Hammerspoon";

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "hammerspoon"
    ];

    home-manager.users.${username}.home.file.".hammerspoon" = {
      source = ./config;
      recursive = true;
    };
  };
}
