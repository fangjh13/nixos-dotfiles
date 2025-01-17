{ pkgs }:

pkgs.writeShellScriptBin "rofi-wo" ''
  rofi -modi wo -show wo -modi wo:~/.config/rofi/scripts/web-open.sh -show-icons
''

