{
  user,
  config,
  pkgs,
  ...
}: let
  xdgConfigHome = config.xdg.configHome;
in {
  # Hammerspoon configuration
  "${xdgConfigHome}/.hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
}
