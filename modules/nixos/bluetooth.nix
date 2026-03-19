{pkgs, ...}: {
  # Bluetooth
  # https://wiki.nixos.org/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };
  # use blueman-applet and blueman-manager
  services.blueman.enable = true;
}
