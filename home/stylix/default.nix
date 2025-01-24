{ pkgs, config, ... }: {

  stylix = {
    enable = true;
    # auto enable targets
    autoEnable = true;
    # disable targets
    targets.neovim.enable = false;
    targets.rofi.enable = false;
    targets.waybar.enable = false;
    targets.hyprland.enable = false;
    targets.hyprlock.enable = false;
    targets.vscode.enable = false;
    targets.gtk.enable = false;
  };
}
