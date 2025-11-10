{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.go = {
    enable = true;
    env = {
      GOPATH = "${config.home.homeDirectory}/.go/";
    };
  };

  # Add a directory to PATH
  home.sessionPath = ["${config.home.homeDirectory}/.go/bin"];
}
