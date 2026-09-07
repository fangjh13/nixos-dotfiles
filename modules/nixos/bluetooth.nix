{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.profiles.desktop.enable {
    # Bluetooth
    # https://wiki.nixos.org/wiki/Bluetooth
    hardware.bluetooth = {
      enable = lib.mkDefault true; # enables support for Bluetooth
      powerOnBoot = lib.mkDefault true; # powers up the default Bluetooth controller on boot
    };
    # use blueman-applet and blueman-manager
    services.blueman.enable = lib.mkDefault true;
  };
}
