{
  hostContext,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  time.timeZone = "Etc/UTC";
  home-manager.users.${hostContext.username}.programs.git.settings.user = {
    name = "Native User";
    email = "native@example.com";
  };
  system.stateVersion = "26.05";
}
