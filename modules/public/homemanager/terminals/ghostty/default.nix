{
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  programs.ghostty = {
    package =
      if isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    settings =
      {
        font-size = 14;
        font-family = "Hack Nerd Font Mono";

        # adjust-cell-height = "30%";
        # window-padding-x = 10;
        # window-padding-y = 10;
        # window-padding-balance = true;

        # theme = "Dracula";
        # theme = "Catppuccin Mocha";
        theme = "TokyoNight Moon";
        # theme = "detuned";

        background-opacity = 0.7;
        background-blur = 20;
        window-decoration = true;
        mouse-hide-while-typing = true;
        shell-integration-features = "ssh-terminfo,ssh-env";
        copy-on-select = "clipboard";

        keybind = [
          "all:unconsumed:ctrl+shift+r=reload_config"
          "global:all:cmd+/=toggle_quick_terminal"
        ];
      }
      // lib.optionalAttrs isDarwin {
        macos-option-as-alt = true;
        macos-titlebar-style = "hidden";
        window-colorspace = "display-p3";
      };
  };
}
