{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window.dynamic_padding = true;
      window.padding = {
        x = 5;
        y = 5;
      };
      scrolling.history = 10000;

      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
}
