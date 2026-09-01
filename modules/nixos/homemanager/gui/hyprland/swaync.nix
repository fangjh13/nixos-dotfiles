{
  pkgs,
  config,
  ...
}: let
  notifyShowBin = pkgs.writeShellScriptBin "notify-show" ''
    sleep 0.1
    ${pkgs.swaynotificationcenter}/bin/swaync-client -t &
  '';
in {
  home.packages = [notifyShowBin];

  # notification daemon
  services.swaync = {
    package = pkgs.swaynotificationcenter;
    enable = true;
  };
}
