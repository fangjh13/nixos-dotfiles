{ pkgs, config, host, ... }: let
  inherit (import ../../hosts/${host}/variables.nix) wallpaper;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
    ];
    extraConfig = {
      modi = "drun,filebrowser,run";
      show-icons = true;
      icon-theme = "Papirus";
      location = 0;
      font = "Noto Sans Regular 12";
      drun-display-format = "{icon} {name}";
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " File";
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#${config.stylix.base16Scheme.base00}";
        bg-alt = mkLiteral "#${config.stylix.base16Scheme.base09}";
        foreground = mkLiteral "#${config.stylix.base16Scheme.base01}";
        selected = mkLiteral "#${config.stylix.base16Scheme.base08}";
        active = mkLiteral "#${config.stylix.base16Scheme.base0B}";
        text-selected = mkLiteral "#${config.stylix.base16Scheme.base00}";
        text-color = mkLiteral "#${config.stylix.base16Scheme.base05}";
        border-color = mkLiteral "#${config.stylix.base16Scheme.base0F}";
        urgent = mkLiteral "#${config.stylix.base16Scheme.base0E}";
      };
      "window" = {
        width = mkLiteral "50%";
        transparency = "real";
        orientation = mkLiteral "vertical";
        cursor = mkLiteral "default";
        spacing = mkLiteral "0px";
        border = mkLiteral "2px";
        border-color = "@border-color";
        border-radius = mkLiteral "20px";
        background-color = mkLiteral "@bg";
      };
      "mainbox" = {
        padding = mkLiteral "15px";
        enabled = true;
        orientation = mkLiteral "vertical";
        children = map mkLiteral [ "inputbar" "listbox" ];
        background-color = mkLiteral "transparent";
      };
      "inputbar" = {
        enabled = true;
        padding = mkLiteral "10px 10px 200px 10px";
        margin = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        border-radius = "25px";
        orientation = mkLiteral "horizontal";
        children = map mkLiteral [ "entry" "dummy" "mode-switcher" ];
        background-image = mkLiteral
          ''url("~/Pictures/Wallpapers/${wallpaper}", width)'';
      };
      "entry" = {
        enabled = true;
        expand = false;
        width = mkLiteral "20%";
        padding = mkLiteral "10px";
        border-radius = mkLiteral "12px";
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@text-selected";
        cursor = mkLiteral "text";
        placeholder = "🖥️ Search ";
        placeholder-color = mkLiteral "inherit";
      };
      "listbox" = {
        spacing = mkLiteral "10px";
        padding = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "vertical";
        children = map mkLiteral [ "message" "listview" ];
      };
      "listview" = {
        enabled = true;
        columns = 2;
        lines = 6;
        cycle = true;
        dynamic = true;
        scrollbar = false;
        layout = mkLiteral "vertical";
        reverse = false;
        fixed-height = false;
        fixed-columns = true;
        spacing = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        border = mkLiteral "0px";
      };
      "dummy" = {
        expand = true;
        background-color = mkLiteral "transparent";
      };
      "mode-switcher" = {
        enabled = true;
        spacing = mkLiteral "10px";
        background-color = mkLiteral "transparent";
      };
      "button" = {
        width = mkLiteral "5%";
        padding = mkLiteral "12px";
        border-radius = mkLiteral "12px";
        background-color = mkLiteral "@text-selected";
        text-color = mkLiteral "@text-color";
        cursor = mkLiteral "pointer";
      };
      "button selected" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@text-selected";
      };
      "scrollbar" = {
        width = mkLiteral "4px";
        border = 0;
        handle-color = mkLiteral "@border-color";
        handle-width = mkLiteral "8px";
        padding = 0;
      };
      "element" = {
        enabled = true;
        spacing = mkLiteral "10px";
        padding = mkLiteral "10px";
        border-radius = mkLiteral "12px";
        background-color = mkLiteral "transparent";
        cursor = mkLiteral "pointer";
      };
      "element normal.normal" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      "element normal.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@foreground";
      };
      "element normal.active" = {
        background-color = mkLiteral "@active";
        text-color = mkLiteral "@foreground";
      };
      "element selected.normal" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@text-selected";
      };
      "element selected.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@text-selected";
      };
      "element selected.active" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@text-selected";
      };
      "element alternate.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };
      "element alternate.urgent" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };
      "element alternate.active" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };
      "element-icon" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        size = mkLiteral "36px";
        cursor = mkLiteral "inherit";
      };
      "element-text" = {
        background-color = mkLiteral "transparent";
        font = "JetBrainsMono Nerd Font Mono 12";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };
      "message" = {
        background-color = mkLiteral "transparent";
        border = mkLiteral "0px";
      };
      "textbox" = {
        padding = mkLiteral "12px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@bg";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };
      "error-message" = {
        padding = mkLiteral "12px";
        border-radius = mkLiteral "20px";
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@bg";
      };
    };

  };

  # 基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容
  # home.file.".config/rofi" = {
  #   source = ./configs;
  #   # copy the scripts directory recursively
  #   recursive = true;
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';
}
