{ pkgs, lib, ... }: {
  environment.pathsToLink = [
    # symlinked in `/run/current-system/sw` to get completion for system packages
    "/share/zsh"
    "/share/bash-completion"
  ];

  # reduce session timeouts when shutting down
  systemd.settings.Manager = {
    DefaultTimeoutStopSec=10;
  };
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
