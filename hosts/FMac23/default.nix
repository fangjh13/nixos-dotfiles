{
  config,
  hostContext,
  ...
}: {
  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "Asia/Shanghai";

  homebrew.casks = [
    "utm"
    "pixpin"
    "orbstack"
    "synology-drive"
    "markedit"
    "obsidian"
    "logseq"
    "antigravity"
    "antigravity-ide"
    "chatgpt"
  ];

  addon.hammerspoon.enable = true;
  addon.karabiner-elements.enable = true;
  addon.input-method.enable = true;

  addon.mihomo = {
    enable = true;
    configFile = config.sops.secrets."mihomo-config".path;
  };

  system.stateVersion = 6;
  system.defaults.finder._FXShowPosixPathInTitle = false;
}
