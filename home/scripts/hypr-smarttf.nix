# hyprland smart toggle floating
# some of apps like kitty toggle to floating set window size
# https://github.com/hyprwm/Hyprland/issues/7926
{pkgs}:
pkgs.writeShellScriptBin "hypr-smarttf" ''

  floating=$(hyprctl activewindow -j | jq '.floating')
  window=$(hyprctl activewindow -j | jq '.initialClass' | tr -d "\"")

  function toggle() {
  	width=$1
  	height=$2

  	hyprctl --batch "dispatch togglefloating; dispatch resizeactive exact $width $height"
  }

  function untoggle() {
  	hyprctl dispatch togglefloating
  }

  function handle() {
  	width=$1
  	height=$2

  	if [ "$floating" == "false" ]; then
  		toggle "$width" "$height"
  	else
  		untoggle
  	fi
  }

  case $window in
  kitty) handle "50%" "55%" ;;
  *) handle "80%" "75%" ;;
  esac

''
