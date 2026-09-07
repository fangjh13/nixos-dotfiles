{pkgs, ...}: {
  imports = [
    ../../modules/public/homemanager/terminals/alacritty
    ../../modules/public/homemanager/terminals/ghostty
    ../../modules/public/homemanager/terminals/wezterm
  ];

  programs = {
    git.settings.user = {
      name = "Fython";
      email = "fython.me@gmail.com";
    };
    ghostty.enable = true;
  };

  home.packages = with pkgs; [
    synology-drive-client
    obsidian
    jetbrains.datagrip
    code-cursor
    antigravity-ide-fhs
    telegram-desktop
    gpu-viewer
    libreoffice
  ];

  gtk.gtk3.bookmarks = [];
}
