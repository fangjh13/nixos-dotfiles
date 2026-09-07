{hostContext, ...}: {
  imports = [./secrets];

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
    "wechat"
    "telegram"
    "feishu"
    "apifox"
    "chatgpt"
    "iina"
    "hiddenbar"
  ];

  addon.hammerspoon.enable = true;
  addon.karabiner-elements.enable = true;
  addon.input-method.enable = true;
  addon.frpc.enable = true;
  addon.mihomo.enable = true;

  system.stateVersion = 6;
}
