{ pkgs, ... }:

{

  # i3 related options
  environment.pathsToLink =
    [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  services.displayManager = { defaultSession = "none+i3"; };

  services.xserver = {
    enable = true;

    desktopManager = { xterm.enable = false; };

    displayManager = {
      lightdm.enable = false;
      gdm.enable = true;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dunst # notification daemon
        i3blocks # status bar
        i3lock # default i3 screen locker
        xautolock # lock screen after some time
        i3status # provide information to i3bar
        i3-gaps # i3 with gaps
        picom # transparency and shadows
        feh # set wallpaper
        acpi # battery information
        arandr # screen layout manager
        dex # autostart applications
        xbindkeys # bind keys to commands
        xorg.xbacklight # control screen brightness
        xorg.xdpyinfo # get screen information
        sysstat # get system information
        imagemagickBig # bitmap images package used for lock screen
        xclip # access the X clipboard from a console application
      ];
    };

    # Configure keymap in X11
    xkb = {
      variant = "";
      options = "ctrl:nocaps"; # Caps Lock as Ctrl
      layout = "us";
    };

    # FIXME specify video drivers
    # Default: videoDrivers = [ "modesetting" "fbdev" ];
    videoDrivers = [ "intel" ];
  };

  # thunar file manager(part of xfce) related options
  environment.systemPackages = with pkgs; [
    xfce.thunar # xfce4's file manager
    xfce.xfconf # thunar need for image preview (https://gitlab.xfce.org/xfce/thunar/-/issues/1285)
  ];
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };
  services.tumbler.enable = true; # Thumbnail support for images preview
  services.gvfs.enable = true; # Mount, trash, and other functionalities
}
