{
  imports = [
    ./local-fonts
    ./fcitx5
    ./xdg
    ./rofi
    ./catppuccin
    ./qt
    ./gtk
    ./hyprland
    ./apps
    ../../../public/homemanager/terminals/alacritty
    ../../../public/homemanager/terminals/wezterm
    ../../../public/homemanager/terminals/kitty
  ];

  home.pointerCursor = {
    enable = true;
    size = 18;
  };
}
