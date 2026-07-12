{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.addon.input-method;
  rimeData = lib.cleanSourceWith {
    src = ../nixos/homemanager/gui/fcitx5/rime-config/share/rime-data;
    filter = path: type: let
      name = builtins.baseNameOf path;
    in
      !(lib.elem name [
        ".git"
        ".gitignore"
      ]);
  };
in {
  options.addon.input-method.enable =
    lib.mkEnableOption "Squirrel input method";

  config = lib.mkIf cfg.enable {
    # Do not remember and automatically restore the input source per document.
    system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
      AppleGlobalTextInputProperties = {
        TextInputGlobalPropertyPerContextInput = false;
      };
    };

    # install Squirrel input method
    homebrew.casks = [
      "squirrel-app"
    ];
    home-manager.users.${username}.home = {
      # install input source switch command line tool
      packages = [pkgs.macism];

      file = {
        "Library/Rime" = {
          source = rimeData;
          recursive = true;
        };
        # Disable Rime Left Shift switching En/Ch by default; macOS uses Karabiner-Elements to switch input source instead.
        "Library/Rime/default.custom.yaml".source = ../nixos/homemanager/gui/fcitx5/rime-custom/default.custom.yaml;
      };
    };
  };
}
