{lib, ...}: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.loader.grub.devices = ["nodev"];
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  system.stateVersion = "26.05";
}
