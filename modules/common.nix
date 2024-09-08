{ pkgs, lib, ... }: {
  environment.pathsToLink = [
    # symlinked in `/run/current-system/sw` to get completion for system packages
    "/share/zsh"
    "/share/bash-completion"
  ];
}
