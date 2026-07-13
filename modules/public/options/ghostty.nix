{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.addon.ghostty;
in {
  options.addon.ghostty.enable = lib.mkEnableOption "Ghostty terminal";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [../homemanager/terminals/ghostty];
      programs.ghostty.enable = true;
    };
  };
}
