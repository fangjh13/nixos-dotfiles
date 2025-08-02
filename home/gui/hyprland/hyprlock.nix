{ config, ... }: {

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
      };
      background = [{
        path = "${config.xdg.userDirs.pictures}/Screenshots/current_wall.png";
        blur_passes = 2; # 0 disables blurring
        blur_size = 6;
        noise = 1.1e-2;
        contrast = 0.89;
        brightness = 0.55;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }];
      input-field = [{
        size = "2%, 5%";
        outline_thickness = 8;
        dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
        inner_color = "rgba(00000000)";
        outer_color = "rgba(00000000)";
        check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
        fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";
        fade_on_empty = true;
        fade_timeout = 3000; # Milliseconds before fade_on_empty is triggered.
        hide_input = true;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        rounding = -1; # -1 means complete rounding (circle/oval)
        position = "0, -20";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
