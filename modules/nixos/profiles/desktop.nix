{
  config,
  hostContext,
  lib,
  ...
}: let
  cfg = config.profiles.desktop;
  inherit (lib) mkEnableOption mkIf mkOption types;
  nonEmptyString = types.addCheck types.str (value: value != "");
  positiveNumber = types.addCheck types.number (value: value > 0);
in {
  imports = [
    ../bluetooth.nix
    ../catppuccin.nix
    ../fonts.nix
    ../wm/hyprland.nix
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "the shared graphical workstation profile";

    defaultTerminal = mkOption {
      type = types.nullOr (types.enum ["ghostty" "kitty" "alacritty" "wezterm"]);
      default = null;
      description = "Terminal used by generic graphical terminal entry points.";
    };

    hyprland = {
      monitors = mkOption {
        type = types.listOf (types.submodule {
          options = {
            output = mkOption {
              type = types.str;
              description = "Hyprland output name, or an empty string for a matching rule.";
            };
            mode = mkOption {
              type = nonEmptyString;
              description = "Hyprland monitor mode.";
            };
            position = mkOption {
              type = nonEmptyString;
              default = "auto";
              description = "Hyprland monitor position.";
            };
            scale = mkOption {
              type = positiveNumber;
              default = 1.0;
              description = "Hyprland monitor scale.";
            };
          };
        });
        default = [];
        description = "Typed Hyprland monitor declarations.";
      };

      xkbOptions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "XKB options applied by Hyprland.";
      };

      sessionVariables = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables exported by Hyprland.";
      };

      extraLua = mkOption {
        type = types.lines;
        default = "";
        description = "Exceptional Host-specific Lua appended to typed Hyprland configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.defaultTerminal != null;
        message = "Host `${hostContext.name}`: profiles.desktop.defaultTerminal must be set when the Desktop profile is enabled";
      }
    ];
    multimedia.pipewire.enable = lib.mkDefault true;
  };
}
