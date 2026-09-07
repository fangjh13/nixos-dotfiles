{pkgs, ...}: {
  imports = [
    ../../modules/public/homemanager/terminals/alacritty
    ../../modules/public/homemanager/terminals/ghostty
    ../../modules/public/homemanager/terminals/wezterm
  ];

  programs = {
    git.settings.user = {
      name = "%%GITNAME%%";
      email = "%%GITEMAIL%%";
    };
    ghostty.enable = true;
  };

  home.packages = with pkgs; [
    telegram-desktop
    gpu-viewer
  ];

  gtk.gtk3.bookmarks = [];
}
