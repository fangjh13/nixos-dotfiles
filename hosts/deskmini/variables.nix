{
  # Hyprland Monitor config
  monitor = ''
    # default
    # monitor=,preferred,auto,auto

    # 4k monitor
    monitor=,preferred,3840x2160@60,2
  '';

  # Choose a wallpaper file name from wallpapers folder
  wallpaper = "SpaceX_20241013_192337_1845545948283572503_photo.jpg";

  timezone = "Asia/Shanghai";

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    "file:///home/fython/Downloads Downloads"
    "file:///home/fython/Documents Documents"
    "file:///home/fython/Pictures Pictures"
    "file:///home/fython/SynologyDrive Drive"
  ];
}

