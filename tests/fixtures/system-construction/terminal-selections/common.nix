{lib, ...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  time.timeZone = "Etc/UTC";
  profiles.desktop.enable = true;
  system.stateVersion = "26.05";
}
