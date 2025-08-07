{pkgs, ...}:
pkgs.writeShellScriptBin "screenlock" ''
  # capture screen
  ${pkgs.grim}/bin/grim -c -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" ~/Pictures/Screenshots/current_wall.png
  # lock screen
  pidof hyprlock || hyprlock
''
