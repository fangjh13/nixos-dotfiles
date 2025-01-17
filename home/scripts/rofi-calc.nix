{ pkgs }:

pkgs.writeShellScriptBin "rofi-calc" ''
  rofi -show calc \
       -modi calc \
       -no-show-match \
       -no-sort \
       -theme ~/.config/rofi/one-col.rasi \
       -calc-command "echo -n '{result}' | wl-copy"
''

