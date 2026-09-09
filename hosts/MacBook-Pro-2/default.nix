{
  hostContext,
  inputs,
  ...
}: {
  imports = [./secrets];

  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "Asia/Shanghai";

  nix-homebrew.taps."hovancik/homebrew-stretchly" = inputs.homebrew-stretchly;

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
    # Reminds you to take regular breaks
    {
      name = "hovancik/stretchly/stretchly";
      postinstall = ''
        /usr/bin/xattr -r -d com.apple.quarantine /Applications/Stretchly.app
      '';
    }
  ];
  homebrew.brews = [
    "mole"
  ];

  addon.hammerspoon.enable = true;
  addon.karabiner-elements.enable = true;
  addon.input-method.enable = true;
  addon.frpc.enable = true;
  addon.mihomo.enable = true;

  system.stateVersion = 6;
}
