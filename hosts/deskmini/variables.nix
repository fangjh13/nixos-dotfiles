{
  userName = "fython";
  hostName = "deskmini";
  gitName = "Fython";
  gitEmail = "fang.jia.hui123@gmail.com";

  timezone = "Asia/Shanghai";

  # Whether to enable the desktop environment
  # If false, only the command-line will be available.
  useGUI = true;

  # Package attribute paths to be installed in the desktop environment.
  # Supports nested package paths such as "jetbrains.datagrip".
  apps = [
    # Synology Drive Client
    "synology-drive-client"
    # Notebook
    "logseq"
    "obsidian"
    # Database GUI
    "jetbrains.datagrip"
    # AI Code Editors
    "code-cursor"
    "antigravity-fhs"

    "telegram-desktop"
    "gpu-viewer"
    "libreoffice"
  ];

  # Extra Hyprland config
  hyprConfig = ''
    # Monitor config
    # See https://wiki.hyprland.org/Configuring/Monitors/
    # monitor=,preferred,auto,auto

    # 4k monitor
    monitor=,preferred,3840x2160@60,2
  '';

  # xkbOptions = "ctrl:nocaps"; # For Keychron Q60Max
  xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin"; # For HHKB (set 1,3,4,5 ON)

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    "file:///home/fython/Downloads Downloads"
    "file:///home/fython/Documents Documents"
    "file:///home/fython/Pictures Pictures"
    "file:///home/fython/SynologyDrive Drive"
  ];
}
