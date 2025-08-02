{ pkgs, ... }:

{
  home.file.".tmux-themepack" = {
    source = ./themepack;
    recursive = true;
  };

  programs = {
    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
