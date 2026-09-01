# https://wiki.archlinux.org/title/Rofi
{
  pkgs,
  config,
  ...
}: let
  dataHome = config.xdg.dataHome;

  rofiLauncherBin = pkgs.writeShellScriptBin "rofi-launcher" ''
    if pgrep -x "rofi" > /dev/null; then
      # Rofi is running, kill it
      pkill -x rofi
      exit 0
    fi
    rofi -show drun
  '';

  rofiCalcBin = pkgs.writeShellScriptBin "rofi-calc" ''
    rofi -show calc \
         -modi calc \
         -no-show-match \
         -no-sort \
         -theme ~/.config/rofi/one-col.rasi \
         -calc-command "echo -n '{result}' | wl-copy"
  '';

  rofiWoBin = pkgs.writeShellScriptBin "rofi-wo" ''
    rofi -modi wo -show wo -modi wo:~/.config/rofi/scripts/web-open.sh -show-icons
  '';

  rofiClipboardBin = pkgs.writeShellScriptBin "rofi-clipboard" ''
    rofi -modi clipboard:~/.config/rofi/scripts/cliphist-rofi-img.sh \
         -show clipboard \
         -show-icons \
         -theme ~/.config/rofi/one-col.rasi
  '';
in {
  programs.rofi = {
    enable = true;
    configPath = "${dataHome}/rofi/config.rasi";
    package = pkgs.rofi;
    plugins = with pkgs; [
      # rofi calculator [https://github.com/svenstaro/rofi-calc]
      (rofi-calc.override {rofi-unwrapped = rofi-unwrapped;})
      # rofi-emoji https://github.com/Mange/rofi-emoji
      # rofi-emoji
    ];
  };

  home.packages = [
    pkgs.rofimoji
    rofiLauncherBin
    rofiCalcBin
    rofiWoBin
    rofiClipboardBin
  ];

  home.file.".config/rofi" = {
    source = ./configs;
    # copy the scripts directory recursively
    recursive = true;
  };
}
