# media - control and view tools audio/video/image
{ pkgs, config, ... }: {

  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = [ "gpu-hq" ];
      scripts = [ pkgs.mpvScripts.mpris ];
    };

    obs-studio.enable = true;

    imv = {
      enable = true;
      package = pkgs.imv.override {
        withBackends = [
          "libjxl"
          "libtiff"
          "libjpeg"
          "libpng"
          "librsvg"
          "libheif"
          "libnsgif"
          # add freeimage to support webp
          # TODO: freeimage-3.18.0-unstable-2024-04-18 package error
          # "freeimage"
        ];
      };
      # https://man.archlinux.org/man/imv.1.en
      settings = {
        # Define some key bindings
        binds = {
          q = "quit";
          # copy file path
          w = "exec echo $imv_current_file | wl-copy";
          # copy image file
          yy = "exec cat $imv_current_file | wl-copy";

          # Image navigation
          "<Left>" = "prev";
          "<bracketleft>" = "prev";
          "<Right>" = "next";
          "<bracketright>" = "next";
          "<Ctrl+h>" = "prev";
          "<Ctrl+l>" = "next";
          gg = "goto 1";
          "<Shift+G>" = "goto -1";

          # Panning
          j = "pan 0 -50";
          k = "pan 0 50";
          h = "pan 50 0";
          l = "pan -50 0";

          # Zooming
          "<Up>" = "zoom 1";
          "<Shift+plus>" = "zoom 1";
          i = "zoom 1";
          "<Down>" = "zoom -1";
          "<minus>" = "zoom -1";
          o = "zoom -1";
          "<Ctrl+0>" = "zoom actual";
          "<Ctrl+equal>" = "zoom 10";
          "<Ctrl+minus>" = "zoom -10";

          # Rotate Clockwise by 90 degrees
          "<Ctrl+r>" = "rotate by 90";

          # Other commands
          x = "close";
          f = "fullscreen";
          d = "overlay";
          p = "exec echo $imv_current_file";
          c = "center";
          s = "scaling next";
          "<Shift+S>" = "upscaling next";
          a = "zoom actual";
          r = "reset";

          # Gif playback
          "<period>" = "next_frame";
          "<space>" = "toggle_playing";

          # Slideshow control
          t = "slideshow +1";
          "<Shift+T>" = "slideshow -1";
        };
      };
    };
  };

  services = { playerctld.enable = true; };
}
