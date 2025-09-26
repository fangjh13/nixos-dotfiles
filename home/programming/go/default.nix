{
  lib,
  pkgs,
  ...
}: {
  programs.go = {
    enable = true;
    env = {
      GOPATH = "$HOME/.go/";
    };
  };

  # Add a directory to PATH
  home.sessionPath = ["$HOME/.go/bin"];
}
