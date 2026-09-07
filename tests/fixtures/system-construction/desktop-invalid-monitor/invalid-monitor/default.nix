{lib, ...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  time.timeZone = "Etc/UTC";
  profiles.desktop = {
    enable = true;
    defaultTerminal = "kitty";
    hyprland.monitors = [
      {
        output = "Virtual-1";
        mode = "1920x1080@60";
        scale = -1.0;
      }
    ];
  };
  system.stateVersion = "26.05";
}
