{
  userName = "fython";
  hostName = "ultrachao";
  gitName = "Fython";
  gitEmail = "fython.me@gmail.com";

  timezone = "Asia/Singapore";

  # Whether to enable the desktop environment
  # If false, only the command-line will be available.
  useGUI = true;

  # Package attribute paths to be installed in the desktop environment.
  # Supports nested package paths such as "jetbrains.datagrip".
  apps = [
    # Synology Drive Client
    "synology-drive-client"
    # Notebook
    # "logseq"
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

  # Extra Hyprland config (Lua format)
  hyprConfig = ''
    -- Monitor config
    -- See https://wiki.hypr.land/Configuring/Monitors/
    -- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

    -- 4k monitor
    hl.monitor({ output = "", mode = "3840x2160@60", position = "auto", scale = 2 })

    --  Nvidia setup
    hl.env("AQ_DRM_DEVICES", "/dev/dri/nvidia-dgpu:/dev/dri/intel-igpu")
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
  '';

  # `ctrl:nocaps` Caps Lock as Ctrl
  # `altwin:swap_lalt_lwin` Left Alt is swapped with Left Win
  xkbOptions = "ctrl:nocaps";

  # Choose a wallpaper file name from wallpapers folder
  wallpaper = "SpaceX_20241013_192337_1845545948283572503_photo.jpg";

  # Bookmarks in the sidebar of the GTK file browser
  bookmarks = [
    # "file:///home/fython/Downloads Downloads"
  ];
}
