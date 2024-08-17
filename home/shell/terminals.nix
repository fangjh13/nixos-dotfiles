{ pkgs, ... }:

# terminals

let font = "Hack Nerd Font Mono";
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.95;
      window.dynamic_padding = true;
      window.padding = {
        x = 5;
        y = 5;
      };
      scrolling.history = 10000;

      font = {
        normal.family = font;
        bold.family = font;
        italic.family = font;
        size = 10;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
}
