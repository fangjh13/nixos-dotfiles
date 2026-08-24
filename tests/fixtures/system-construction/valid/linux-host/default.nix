{
  lib,
  hostContext,
  packageSets,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  assertions = [
    {
      assertion = hostContext.system == "x86_64-linux";
      message = "fixture did not receive its namespaced Host context";
    }
    {
      assertion = packageSets.stable.stdenv.hostPlatform.system == "x86_64-linux";
      message = "fixture stable package set does not match its Host system";
    }
    {
      assertion = packageSets.unstable.stdenv.hostPlatform.system == "x86_64-linux";
      message = "fixture unstable package set does not match its Host system";
    }
  ];
  boot.loader.grub.devices = ["nodev"];
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  system.stateVersion = "26.05";
}
