{
  config,
  host,
  pkgs,
  username,
  ...
}: {
  addon.hammerspoon.enable = true;
  addon.karabiner-elements.enable = true;
  addon.input-method.enable = true;
  addon.ghostty.enable = true;

  addon.mihomo = {
    enable = true;
    configFile = config.sops.secrets."mihomo-config".path;
  };

  # Override: disable full POSIX path in Finder title bar
  system.defaults.finder._FXShowPosixPathInTitle = false;
}
