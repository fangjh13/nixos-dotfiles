{ pkgs, wallpaper, ... }: {
  # stylix options
  # https://stylix.danth.me/options/nixos.html
  stylix = {
    enable = true;
    # auto enable targets
    autoEnable = true;
    # set background image and auto generate a colour scheme
    image = ../. + "/wallpapers/${wallpaper}";
    polarity = "dark";
    opacity.terminal = 0.9;
    cursor.package = pkgs.capitaine-cursors;
    cursor.name = "capitaine-cursors";
    cursor.size = 24;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji-blob-bin;
      };
    };
  };
}
