{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.addon.docker;
in {
  options.addon.docker = {
    enable = mkEnableOption "Enable Docker";

    storageDriver = mkOption {
      type = types.nullOr (types.enum [
        "aufs"
        "btrfs"
        "devicemapper"
        "overlay"
        "overlay2"
        "zfs"
      ]);
      default = null;
      description = "Docker storage driver.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      # start on demand by socket activation
      enableOnBoot = false;
      storageDriver = cfg.storageDriver;
    };
    users.users."${username}".extraGroups = ["docker"];
  };
}
