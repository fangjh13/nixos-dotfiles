{
  pkgs,
  config,
  ...
}: {
  stylix = {
    enable = true;
    # auto enable targets
    autoEnable = true;
    # disable targets
    # reference: https://stylix.danth.me/options/modules/neovim.html
    targets.neovim.enable = false;
    targets.rofi.enable = false;
    targets.waybar.enable = false;
    targets.hyprland.enable = false;
    targets.hyprlock.enable = false;
    targets.vscode.enable = false;
    targets.gtk.enable = false;
    targets.qt.enable = false;
    targets.kitty.enable = false;
    targets.fcitx5.enable = false;
    targets.fzf.enable = false;

    # firefox use default profile
    targets.firefox.profileNames = ["default"];
  };
}
