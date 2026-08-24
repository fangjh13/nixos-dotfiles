{inputs}: {
  hostsPath,
  hostName,
}: let
  constructInventory = import ./system-construction.nix {inherit inputs;};
  outputs = constructInventory hostsPath;
  host = outputs.inventory.${hostName};
  configuration =
    if host.platform == "linux"
    then outputs.nixosConfigurations.${hostName}
    else outputs.darwinConfigurations.${hostName};
in
  builtins.deepSeq [
    host
    configuration.config.nixpkgs.hostPlatform.system
    configuration.config.system.stateVersion
    configuration.config.system.build.toplevel.drvPath
  ] true
