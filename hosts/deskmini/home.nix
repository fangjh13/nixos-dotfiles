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

  home.packages = [pkgs.gpu-viewer];

  gtk.gtk3.bookmarks = [
    "file:///home/fython/Downloads Downloads"
    "file:///home/fython/Documents Documents"
    "file:///home/fython/Pictures Pictures"
  ];
}
