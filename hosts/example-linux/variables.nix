{
  userName = "%%USERNAME%%";
  hostName = "%%HOSTNAME%%";
  gitName = "%%GITNAME%%";
  gitEmail = "%%GITEMAIL%%";

  timezone = "%%TIMEZONE%%";

  # Whether to enable the desktop environment
  # If false, only the command-line will be available.
  useGUI = true;

  # Package attribute paths to be installed in the desktop environment.
  # Supports nested package paths such as "jetbrains.datagrip".
  apps = [
    "telegram-desktop"
    "gpu-viewer"
  ];

  # Extra Hyprland config
  hyprConfig = ''
    # Monitor config
    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=,preferred,auto,auto
    # 4k monitor like this
    # monitor=,preferred,3840x2160@60,2

    # Nvidia setup
    # env = LIBVA_DRIVER_NAME,nvidia
    # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  '';

  # `ctrl:nocaps` Caps Lock as Ctrl
  # `altwin:swap_lalt_lwin` Left Alt is swapped with Left Win
  xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin";

  # Choose a wallpaper file name from wallpapers folder
  wallpaper = "SpaceX_20241013_192337_1845545948283572503_photo.jpg";

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    # "file:///home/fython/Downloads Downloads"
  ];
}
