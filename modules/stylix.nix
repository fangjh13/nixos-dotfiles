{pkgs, wallpaper, ...}: {
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
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
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
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
