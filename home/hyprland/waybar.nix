{ pkgs, lib, config, ... }:

let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  clock24h = true;
in with lib; {
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [{
      layer = "top";
      position = "top";
      modules-center = [ "hyprland/workspaces" ];
      modules-left =
        [ "custom/startmenu" "hyprland/window" "pulseaudio" "cpu" "memory" ];
      modules-right = [
        "network"
        "idle_inhibitor"
        "custom/notification"
        "custom/exit"
        "battery"
        "tray"
        "clock"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        format-icons = {
          default = " ";
          active = " ";
          urgent = " ";
        };
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock" = {
        format = if clock24h then " {:L%H:%M}" else " {:L%I:%M %p}";
        format-alt = " {:%A, %B %d, %Y (%R)}";
        tooltip = true;
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };
      "hyprland/window" = {
        max-length = 22;
        separate-outputs = false;
        rewrite = { "" = " 🙈 No Windows? "; };
      };
      "memory" = {
        interval = 5;
        format = " {}%";
        tooltip = true;
      };
      "cpu" = {
        interval = 5;
        format = " {usage:2}%";
        tooltip = true;
      };
      "disk" = {
        format = " {free}";
        tooltip = true;
      };
      "network" = {
        interval = 1;
        format-alt = "{ifname} {gwaddr}";
        format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        format-wifi = "{icon}  {bandwidthDownBytes}  {bandwidthUpBytes} ";
        format-ethernet = "{icon}  {bandwidthDownBytes}  {bandwidthUpBytes} ";
        format-disconnected = "󰌙";
        tooltip-format = "{essid} {signalStrength}% {ifname} via {gwaddr}";
        format-linked = "󰈁 {ifname} (No IP)";
        tooltip-format-wifi =
          "{essid} {ipaddr} {icon} {signalStrength}% {frequency}GHz";
        tooltip-format-ethernet = "{ifname} {ipaddr} 󰌘";
        tooltip-format-disconnected = "󰌙 Disconnected";
        max-length = 30;
      };
      "tray" = { spacing = 12; };
      "pulseaudio" = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "sleep 0.1 && pavucontrol";
      };
      "custom/exit" = {
        tooltip = false;
        format = "";
        on-click = "sleep 0.1 && wlogout";
      };
      "custom/startmenu" = {
        tooltip = false;
        format = "";
        # exec = "rofi -show drun";
        on-click = "sleep 0.1 && rofi-launcher";
      };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        tooltip = "true";
      };
      "custom/notification" = {
        tooltip = false;
        format = "{icon} {}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification =
            "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification =
            "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "sleep 0.1 && notify-show";
        escape = true;
      };
      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󱘖 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        on-click = "";
        tooltip = false;
      };
    }];
    style = ''
      * {
        font-family: Noto Sans Mono;
        font-size: 12px;
        border-radius: 0px;
        border: none;
        min-height: 0px;
      }
      window#waybar {
        background: rgba(0,0,0,0);
      }
      #workspaces {
        color: #${config.stylix.base16Scheme.base00};
        background: #${config.stylix.base16Scheme.base01};
        margin: 4px 4px;
        padding: 5px 5px;
        border-radius: 16px;
      }
      #workspaces button {
        font-weight: bold;
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 16px;
        color: #${config.stylix.base16Scheme.base00};
        background: linear-gradient(45deg, #${config.stylix.base16Scheme.base08}, #${config.stylix.base16Scheme.base0D});
        opacity: 0.5;
        transition: ${betterTransition};
      }
      #workspaces button.active {
        font-weight: bold;
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 16px;
        color: #${config.stylix.base16Scheme.base00};
        background: linear-gradient(45deg, #${config.stylix.base16Scheme.base08}, #${config.stylix.base16Scheme.base0D});
        transition: ${betterTransition};
        opacity: 1.0;
        min-width: 40px;
      }
      #workspaces button:hover {
        font-weight: bold;
        border-radius: 16px;
        color: #${config.stylix.base16Scheme.base00};
        background: linear-gradient(45deg, #${config.stylix.base16Scheme.base08}, #${config.stylix.base16Scheme.base0D});
        opacity: 0.8;
        transition: ${betterTransition};
      }
      tooltip {
        background: #${config.stylix.base16Scheme.base00};
        border: 1px solid #${config.stylix.base16Scheme.base08};
        border-radius: 12px;
      }
      tooltip label {
        color: #${config.stylix.base16Scheme.base08};
      }
      #window, #pulseaudio, #cpu, #memory {
        font-weight: bold;
        margin: 4px 0px;
        margin-left: 7px;
        padding: 0px 18px;
        background: #${config.stylix.base16Scheme.base04};
        color: #${config.stylix.base16Scheme.base00};
        border-radius: 24px 10px 24px 10px;
      }
      #custom-startmenu {
        color: #${config.stylix.base16Scheme.base0B};
        background: #${config.stylix.base16Scheme.base02};
        font-size: 28px;
        margin: 0px;
        padding: 0px 28px 0px 13px;
        border-radius: 0px 0px 40px 0px;
      }
      #idle_inhibitor, #battery,
      #custom-notification, #tray, #custom-exit {
        font-weight: bold;
        background: #${config.stylix.base16Scheme.base0F};
        color: #${config.stylix.base16Scheme.base00};
        margin: 4px 0px;
        margin-right: 7px;
        border-radius: 10px 24px 10px 24px;
        padding: 0px 18px;
      }
      #network {
        color: #${config.stylix.base16Scheme.base05};
        border: 1px solid #${config.stylix.base16Scheme.base05};
        background: transparent;
        font-weight: bold;
        margin: 4px 0px;
        margin-right: 7px;
        border-radius: 10px 24px 10px 24px;
        padding: 0px 18px;
      }
      #clock {
        font-weight: bold;
        color: #0D0E15;
        background: linear-gradient(90deg, #${config.stylix.base16Scheme.base0E}, #${config.stylix.base16Scheme.base0C});
        margin: 0px;
        padding: 0px 8px 0px 15px;
        border-radius: 0px 0px 0px 40px;
      }
    '';
  };
}

