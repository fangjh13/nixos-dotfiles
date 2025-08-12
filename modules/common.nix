{
  pkgs,
  lib,
  ...
}: {
  # reduce session timeouts when shutting down
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = 10;
  };
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
