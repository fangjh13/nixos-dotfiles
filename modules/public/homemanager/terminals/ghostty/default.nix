{
  lib,
  pkgs,
  hostContext,
  ...
}: let
  isDarwin = hostContext.platform == "darwin";
in {
  programs.ghostty = {
    package =
      if isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    settings =
      {
        font-size = 13.0;
        font-style = "Regular";
        font-family = "JetBrainsMono Nerd Font Mono";
        font-thicken = true;
        adjust-cell-height = "20%";

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
        clipboard-read = "allow";
        clipboard-write = "allow";

        keybind = [
          "all:unconsumed:ctrl+shift+r=reload_config"
          "global:all:cmd+/=toggle_quick_terminal"
          "cmd+enter=toggle_split_zoom"
          "alt+enter=toggle_fullscreen"
          # open scrollback in editor
          "ctrl+shift+h=write_scrollback_file:open"
          # coustom view mode, vim mode for navigation
          "alt+v=activate_key_table:vim"
          "vim/"
          "vim/j=scroll_page_lines:1"
          "vim/k=scroll_page_lines:-1"
          "vim/ctrl+d=scroll_page_down"
          "vim/ctrl+u=scroll_page_up"
          "vim/g>g=scroll_to_top"
          "vim/shift+g=scroll_to_bottom"
          "vim/escape=deactivate_key_table"
          "vim/q=deactivate_key_table"
          "vim/i=deactivate_key_table"
          "vim/catch_all=ignore"
        ];
      }
      // lib.optionalAttrs isDarwin {
        macos-option-as-alt = true;
        macos-titlebar-style = "transparent";
        window-colorspace = "display-p3";
      };
  };
}
