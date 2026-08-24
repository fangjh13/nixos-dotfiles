{
  gitName = "Fython";
  gitEmail = "fython.me@gmail.com";

  timezone = "Asia/Singapore";

  # Whether to enable the desktop environment
  # If false, only the command-line will be available.
  useGUI = true;

  # Package attribute paths to be installed in the desktop environment.
  # Supports nested package paths such as "jetbrains.datagrip".
  apps = [
    "gpu-viewer"
  ];

  # Extra Hyprland config
  hyprConfig = ''
    hl.monitor({ output = "", mode = "3840x2160@60", position = "auto", scale = 2 })
  '';

  # xkbOptions = "ctrl:nocaps"; # For Keychron Q60Max
  xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin"; # For HHKB (set 1,3,4,5 ON)

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    "file:///home/fython/Downloads Downloads"
    "file:///home/fython/Documents Documents"
    "file:///home/fython/Pictures Pictures"
    # "file:///home/fython/SynologyDrive Drive"
  ];
}
