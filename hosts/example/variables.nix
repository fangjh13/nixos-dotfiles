{
  # Whether to enable the desktop environment
  # If false, only the command-line will be available.
  useGUI = true;

  # Hyprland Monitor config
  monitor = ''
    monitor=,preferred,auto,auto
    # or 4k monitor like this
    # monitor=,preferred,3840x2160@60,2
  '';

  # `ctrl:nocaps` Caps Lock as Ctrl
  # `altwin:swap_lalt_lwin` Left Alt is swapped with Left Win
  xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin";

  # Choose a wallpaper file name from wallpapers folder
  wallpaper = "SpaceX_20241013_192337_1845545948283572503_photo.jpg";

  timezone = "Asia/Shanghai";

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    # "file:///home/fython/Downloads Downloads"
  ];
}
