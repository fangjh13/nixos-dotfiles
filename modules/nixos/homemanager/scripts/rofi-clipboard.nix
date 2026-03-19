{pkgs}:
pkgs.writeShellScriptBin "rofi-clipboard" ''
  rofi -modi clipboard:~/.config/rofi/scripts/cliphist-rofi-img.sh \
       -show clipboard \
       -show-icons \
       -theme ~/.config/rofi/one-col.rasi
''
