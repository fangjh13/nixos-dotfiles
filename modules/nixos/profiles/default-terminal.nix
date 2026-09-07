{
  ghostty = {
    command = "ghostty";
    execute = program: "ghostty -e ${program}";
    floating = program: "ghostty --title=FloatWindow -e ${program}";
    module = ../../public/homemanager/terminals/ghostty;
  };

  kitty = {
    command = "kitty";
    execute = program: "kitty --execute ${program}";
    floating = program: "kitty -T FloatWindow --execute ${program}";
    module = ../../public/homemanager/terminals/kitty;
  };

  alacritty = {
    command = "alacritty";
    execute = program: "alacritty -e ${program}";
    floating = program: "alacritty --title FloatWindow -e ${program}";
    module = ../../public/homemanager/terminals/alacritty;
  };

  wezterm = {
    command = "wezterm start";
    execute = program: "wezterm start -- ${program}";
    floating = program: "wezterm start --class FloatWindow -- ${program}";
    module = ../../public/homemanager/terminals/wezterm;
  };
}
