{
  config,
  pkgs,
  ...
}: let
  xdgConfigHome = config.xdg.configHome;
  home = config.home.homeDirectory;
in {
  # Hammerspoon configuration
  "${home}/.hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
}
