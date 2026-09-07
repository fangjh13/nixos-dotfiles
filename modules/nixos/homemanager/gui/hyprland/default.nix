{
  desktopProfile,
  desktopTerminal,
  pkgs,
  lib,
  ...
}: let
  cfg = desktopProfile.hyprland;
  luaString = builtins.toJSON;
  monitorConfig =
    lib.concatMapStringsSep "\n" (monitor: ''
      hl.monitor({ output = ${luaString monitor.output}, mode = ${luaString monitor.mode}, position = ${luaString monitor.position}, scale = ${builtins.toString monitor.scale} })
    '')
    cfg.monitors;
  sessionVariableConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
      hl.env(${luaString name}, ${luaString value})
    '')
    cfg.sessionVariables);
  hyprConfig = lib.concatStringsSep "\n" (builtins.filter (value: value != "") [
    monitorConfig
    sessionVariableConfig
    cfg.extraLua
  ]);
  xkbOptions = lib.concatStringsSep "," cfg.xkbOptions;
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
          ["@HYPR_CONFIG@" "@XKB_OPTIONS@" "@TERMINAL@"]
          [hyprConfig xkbOptions desktopTerminal.command]
          (builtins.readFile ./hyprland-config.lua);
      };
    };
  }
