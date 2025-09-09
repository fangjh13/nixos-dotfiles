{
  lib,
  pkgs,
  ...
}: {
  programs.go = {
    enable = true;
    goPath = ".go/";
  };

  # Add a directory to PATH
  home.sessionPath = ["$HOME/.go/bin"];
}
