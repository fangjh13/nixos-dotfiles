{ pkgs, config, ... }: {
  # i3 配置，基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容

  home.file.".config/i3/config".source = ./config;
  home.file.".config/i3/i3blocks.conf".source = ./i3blocks.conf;
  home.file.".config/i3/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true; # make all scripts executable
  };
  home.file.".config/i3status" = {
    source = ./i3status;
    recursive = true;
  };
  # wallpaper, binary file
  home.file.".config/i3/wallpapers" = {
    source = ../../wallpapers;
    recursive = true;
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = { "Xft.dpi" = 192; };

  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
    size = 40;
  };

  home.sessionVariables.GTK_THEME = "WhiteSur-Dark-solid";
  gtk = {
    enable = true;
    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    theme = {
      # name = "WhiteSur-Dark";
      name = "WhiteSur-Dark-solid";
      package = pkgs.whitesur-gtk-theme.override { nautilusSize = "180"; };
    };
    cursorTheme = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 40;
    };
    # The font to use in GTK+ 2/3 applications.
    font = {
      name = "Noto Sans";
      size = 10;
    };
    gtk3 = {
      # FIXME Bookmarks in the sidebar of the GTK file browser
      bookmarks = [ "file:///home/fython/SynologyDrive Drive" ];
    };
  };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

}
