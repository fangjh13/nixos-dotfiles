{ config, lib, pkgs, ... }:
let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in {
  imports = [ ./bash ./zsh ./prompt/starship.nix ./terminals/alacritty ];

  # add environment variables
  home.sessionVariables = {
    TZ = "/etc/localtime";

    # clean up ~
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    WINEPREFIX = d + "/wine";

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
  };

  home.shellAliases = { k = "kubectl"; };
}
