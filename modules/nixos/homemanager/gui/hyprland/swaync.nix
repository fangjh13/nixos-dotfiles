{
  pkgs,
  config,
  ...
}: {
  # notification daemon
  services.swaync = {
    package = pkgs.swaynotificationcenter;
    enable = true;
  };
}
