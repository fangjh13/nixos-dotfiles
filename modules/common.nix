{ pkgs, lib, ... }: {
  environment.pathsToLink = [
    # symlinked in `/run/current-system/sw` to get completion for system packages
    "/share/zsh"
    "/share/bash-completion"
  ];

  # reduce session timeouts when shutting down
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
