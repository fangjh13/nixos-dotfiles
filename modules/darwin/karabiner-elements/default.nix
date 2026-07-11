{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.addon.karabiner-elements;
in {
  options.addon.karabiner-elements.enable =
    lib.mkEnableOption "Karabiner-Elements";

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "karabiner-elements"
    ];

    home-manager.users.${username}.xdg.configFile."karabiner/karabiner.json" = {
      source = ./karabiner.json;

      onChange = ''
        uid=$(/usr/bin/id -u)
        service=org.pqrs.service.agent.karabiner_console_user_server

        if /bin/launchctl print "gui/$uid/$service" >/dev/null 2>&1; then
          /bin/launchctl kickstart -k "gui/$uid/$service"
        fi
      '';
    };
  };
}
