{
  hostContext,
  packageSets,
  ...
}: {
  assertions = [
    {
      assertion = hostContext.platform == "darwin";
      message = "fixture did not receive the derived Darwin platform";
    }
    {
      assertion = packageSets.stable.stdenv.hostPlatform.system == "aarch64-darwin";
      message = "fixture stable package set does not match its Host system";
    }
  ];
  system.stateVersion = 6;
}
