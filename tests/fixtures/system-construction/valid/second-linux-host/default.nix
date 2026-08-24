{lib, ...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.loader.grub.devices = ["nodev"];
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  system.stateVersion = "26.05";
}
