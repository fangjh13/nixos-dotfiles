# https://wiki.archlinux.org/title/Rofi
{
  pkgs,
  config,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) wallpaper;
  dataHome = config.xdg.dataHome;
in {
  programs.rofi = {
    enable = true;
    configPath = "${dataHome}/rofi/config.rasi";
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      # rofi calculator [https://github.com/svenstaro/rofi-calc]
      (rofi-calc.override {rofi-unwrapped = rofi-wayland-unwrapped;})
      # rofi-emoji https://github.com/Mange/rofi-emoji
      rofi-emoji-wayland
    ];
  };

  home.file.".config/rofi" = {
    source = ./configs;
    # copy the scripts directory recursively
    recursive = true;
  };
}
