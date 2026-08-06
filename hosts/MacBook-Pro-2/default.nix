{
  config,
  host,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./secrets
  ];

  addon.hammerspoon.enable = true;
  addon.karabiner-elements.enable = true;
  addon.input-method.enable = true;
  addon.ghostty.enable = true;

  addon.frpc = {
    enable = true;
    configFile = config.sops.secrets."frpc-config".path;
  };

  addon.sing-box = {
    enable = false;
    configFile = config.sops.secrets."sing-box-config".path;
  };

  addon.mihomo = {
    enable = true;
    configFile = config.sops.secrets."mihomo-config".path;
  };
}
