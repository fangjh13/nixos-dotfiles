{
  pkgs,
  lib,
  ...
}: {
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Docs
  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
    dev.enable = true;
  };

  # reduce session timeouts when shutting down
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = 10;
  };
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
