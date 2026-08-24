{
  lib,
  inputs,
  hostContext,
  ...
}: let
  inherit (hostContext.settings) useGUI;
  sourceFor = import ../../../../../lib/catppuccin-source.nix {inherit inputs;};
  parseSimpleIni = import ../../../../../lib/parse-simple-ini.nix {inherit lib;};
in {
  catppuccin = {
    enable = true;
    autoEnable = useGUI;

    flavor = "mocha";
    accent = "mauve";
    sources = {
      starship = sourceFor "starship" + "/themes";
      waybar = sourceFor "waybar" + "/themes";
    };

    cursors = {
      enable = true;
      accent = "dark";
    };

    # Disable targets that have custom configs
    hyprlock.enable = false;
    firefox.enable = false;
    fcitx5.enable = false;
    # Preserve the same theme without Catppuccin's target-platform INI converter.
    imv.enable = false;
    delta.enable = false;
    nvim.enable = false;
  };

  programs.imv.settings = parseSimpleIni (sourceFor "imv" + "/themes/mocha.config");
}
