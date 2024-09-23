{ config, lib, pkgs, ... }:
let
  dataHome = config.xdg.dataHome;
  configHome = config.xdg.configHome;
  cacheHome = config.xdg.cacheHome;
in {
  imports = [ ./bash ./zsh ./prompt/starship.nix ./terminals/alacritty ./terminals/wezterm ];

  # add environment variables
  home.sessionVariables = {
    TZ = "/etc/localtime";

    # set default applications
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";

    # colorizing the man pager with bat
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    # fix man with bat color (https://github.com/sharkdp/bat/issues/652)
    MANROFFOPT = "-c";

    # journalctl ignore case
    SYSTEMD_LESS = "-iFRSXMK";
  };

  home.shellAliases = { k = "kubectl"; };

  # Add a directory to PATH
  home.sessionPath = [ "$HOME/.go/bin" "$HOME/.local/bin" ];
}
