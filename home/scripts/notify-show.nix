{ pkgs }:

pkgs.writeShellScriptBin "notify-show" ''
  sleep 0.1
  ${pkgs.swaynotificationcenter}/bin/swaync-client -t &
''

