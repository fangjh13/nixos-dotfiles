{
  pkgs,
  lib,
  username,
  host,
  config,
  inputs,
  ...
} @ args: let
  inherit (import ../../../../../hosts/${host}/variables.nix) hyprConfig xkbOptions;
in
  with lib; {
    imports = [
      ./wlogout
      ./hypridel.nix
      ./hyprlock.nix
      ./waybar.nix
      ./swaync.nix
      ./cliphist.nix
      ./screenshot.nix
    ];

    home.packages = with pkgs; [
      # Color pickers
      hyprpicker
      # Wayland clipboard utilities (wl-copy and wl-paste)
      wl-clipboard
      # Wayland event viewer debug tool
      wev
      # Xorg tools `xprop` for debugging X11(Xwayland) applications
      xprop
      # control device brightness
      brightnessctl
    ];

    # Enable Ozone Wayland support chromium and Electron based applications
    # This allows these applications to run without Xwayland
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd = {
        enable = true;
        variables = ["--all"];
      };
      extraLuaFiles.config = {
        autoLoad = true;
        content =
          builtins.replaceStrings
          ["@HYPR_CONFIG@" "@XKB_OPTIONS@"]
          [hyprConfig xkbOptions]
          (builtins.readFile ./hyprland-config.lua);
      };
    };
  }
