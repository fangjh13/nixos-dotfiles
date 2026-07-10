{
  config,
  pkgs,
  ...
}: {
  services.karabiner-elements.enable = true;

  xdg.configFile."karabiner/karabiner.json".source = {
    source = ./karabiner.json;

    onChange = ''
      /bin/launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
    '';
  };
}
