{ lib, config, username, storageDriver ? null, ... }:
with lib;
assert assertOneOf "Docker: storageDriver" storageDriver [
  null
  "aufs"
  "btrfs"
  "devicemapper"
  "overlay"
  "overlay2"
  "zfs"
];
let cfg = config.addon.docker;
in {
  options.addon.docker = { enable = mkEnableOption "Enable Docker"; };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      # start on demand by socket activation
      enableOnBoot = false;
      storageDriver = storageDriver;
    };
    users.users."${username}".extraGroups = [ "docker" ];
  };
}

