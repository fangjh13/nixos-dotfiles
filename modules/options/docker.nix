{ lib, config, username, ... }:
with lib;
let cfg = config.addon.docker;
in {
  options.addon.docker = { enable = mkEnableOption "Enable Docker"; };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };

    users.users."${username}".extraGroups = [ "docker" ];
  };
}

