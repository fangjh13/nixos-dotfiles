{desktopTerminal, ...}: {
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
    desktopTerminal.module
  ];

  home.pointerCursor = {
    enable = true;
    size = 18;
  };
}
