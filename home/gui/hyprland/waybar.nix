{
  pkgs,
  lib,
  host,
  config,
  ...
}: let
  clock24h = true;
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../../../hosts/${host}/variables.nix) timezone;
in
  with lib; {
    # Configure & Theme Waybar
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          position = "top";
          modules-left = [
            "custom/startmenu"
            "hyprland/workspaces"
            "group/screentools"
            "idle_inhibitor"
            "hyprland/window"
            "custom/playerctl"
            "custom/playerlabel"
          ];
          modules-center = [
            "hyprland/submap"
            # "temperature"
            "group/cpuinfo"
            "memory"
          ];
          modules-right = [
            "tray"
            "bluetooth"
            "pulseaudio"
            "group/network"
            "custom/notification"
            "battery"
            "clock"
            "custom/exit"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              default = "";
              active = "<span color='#0f0'></span>";
              urgent = "";
            };
            tooltip = false;
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "clock" = {
            timezone = "${timezone}";
            format =
              if clock24h
              then " {:L%H:%M}"
              else " {:L%I:%M %p}";
            format-alt = "<span color='#eba0ac'> </span> <span color='#cdd6f4'>{:%Y-%m-%d}</span>";
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
            max-length = 16;
            separate-outputs = false;
            rewrite = {"" = " 🙈 No Windows? ";};
          };
          "memory" = {
            interval = 5;
            tooltip = true;
            format = "󰾆 {}%";
            format-alt = "󰾅 {used}/{total} GiB";
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            format-alt = " {avg_frequency} GHz";
            tooltip = true;
            on-scroll-up = "";
            on-scroll-down = "";
          };
          "disk" = {
            format = " {free}";
            tooltip = true;
          };
          "group/network" = {
            orientation = "inherit";
            on-scroll-up = "";
            on-scroll-down = "";
            drawer = {
              transition-duration = 500;
              transition-left-to-right = true;
            };
            modules = ["network#brif" "network"];
          };
          "network#brif" = {
            format = "{icon}";
            format-icons = {
              wifi = ["󰤨"];
              ethernet = ["󰈀"];
              disconnected = ["󰖪"];
            };
            format-wifi = "󰤨";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            format-linked = "󰈁";
            on-scroll-up = "";
            on-scroll-down = "";
          };

          "network" = {
            interval = 1;
            format-alt = "{ifname} via {gwaddr}";
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            format-wifi = "  {bandwidthDownBytes}  {bandwidthUpBytes} ";
            format-ethernet = "󰈀  {bandwidthDownBytes}  {bandwidthUpBytes} ";
            format-disconnected = "󰌙";
            tooltip-format = "{essid} {signalStrength}% {ifname} via {gwaddr}";
            format-linked = "󰈁 {ifname} (No IP)";
            tooltip-format-wifi = "{essid} {ipaddr} {icon} {signalStrength}% {frequency}GHz";
            tooltip-format-ethernet = "{ifname} {ipaddr} 󰈀";
            tooltip-format-disconnected = "󰌙 Disconnected";
            max-length = 30;
            on-scroll-up = "";
            on-scroll-down = "";
          };
          # "temperature" = {
          #   critical-threshold = 80;
          #   format = "{icon} {temperatureC}°C";
          #   format-icons = [ "" "" "" ];
          # };
          "tray" = {spacing = 12;};
          "pulseaudio" = {
            format = "<span color='#f79902'>{icon}</span> {volume}% <span color='#FF4500'></span> {format_source}";
            format-bluetooth = "{volume}% <span color='#f79902'>{icon}</span> <span color='#FF4500'></span> {format_source}";
            format-bluetooth-muted = "<span color='#f79902'> {icon}</span> <span color='#FF4500'></span> {format_source}";
            format-muted = "  <span color='#FF4500'></span> {format_source}";
            format-source = "<span color='#f79902'></span> {volume}%";
            format-source-muted = "";
            format-icons = {
              default = ["" "" ""];
              hdmi = "󰽟";
              hdmi-muted = "󰽠";
              default-muted = "";
              speaker = "󰽟";
              hifi = "";
              car = "";
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              phone-muted = "";
              portable = "";
            };
            on-click = "sleep 0.1 && pavucontrol";
            on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-middle = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            scroll-step = 5;
            tooltip = false;
          };
          "custom/exit" = {
            tooltip = false;
            format = "<span color='#99ffdd'></span>";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = "{icon}";
            format-icons = "<span color='#99ffdd'></span>";
            on-click = "sleep 0.1 && rofi-launcher";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "<span color='#D7474B'></span>";
              deactivated = "<span color='#5F70F6'></span>";
            };
            tooltip = "true";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {text}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
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
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            on-click = "";
            tooltip = false;
          };
          "group/screentools" = {
            orientation = "inherit";
            on-scroll-up = "";
            on-scroll-down = "";
            drawer = {
              transition-duration = 500;
              transition-left-to-right = true;
            };
            modules = [
              "custom/screen" # first element
              "custom/snip"
              "custom/picker"
            ];
          };
          "custom/screen" = {
            format = "󰹑";
            # on-click = "nwg-displays";
            tooltip-format = "Screen";
            on-scroll-up = "";
            on-scroll-down = "";
          };
          "custom/snip" = {
            format = "";
            on-click = "sleep 0.1 && screenshot";
            tooltip-format = "Screenshot";
            on-scroll-up = "";
            on-scroll-down = "";
          };
          "custom/picker" = {
            format = "";
            on-click = "hyprpicker -a";
            tooltip-format = "Hyprpicker";
            on-scroll-up = "";
            on-scroll-down = "";
          };
          "custom/playerctl" = {
            format = "{icon}";
            return-type = "json";
            max-length = 48;
            exec = ''
              playerctl --player=firefox metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
            on-click-middle = "playerctl --player=firefox play-pause";
            on-click = "playerctl --player=firefox previous";
            on-click-right = "playerctl --player=firefox next";
            format-icons = {
              Playing = "";
              Paused = "";
            };
            tooltip = false;
          };

          "custom/playerlabel" = {
            format = "{}";
            return-type = "json";
            max-length = 48;
            exec = ''
              playerctl --player=firefox metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
            on-click-middle = "playerctl --player=firefox play-pause";
            on-click = "playerctl --player=firefox previous";
            on-click-right = "playerctl --player=firefox next";
            tooltip = false;
          };

          "hyprland/submap" = {
            format = "󰩨  {}";
            max-length = 128;
            tooltip = false;
          };

          "group/cpuinfo" = {
            orientation = "inherit";
            on-scroll-up = "";
            on-scroll-down = "";
            drawer = {
              transition-duration = 500;
              transition-left-to-right = true;
            };
            modules = ["cpu" "custom/cputemp"];
          };

          "custom/cputemp" = {
            format = " {}°C";
            exec = "cpu-temp";
            interval = 8;
            tooltip-format = "Cpu Temp";
            on-click = "kitty -T FloatWindow --execute btop";
            on-scroll-up = "";
            on-scroll-down = "";
          };

          "custom/gputemp" = {
            format = " {}°C";
            exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
            exec-if = "command -v nvidia-smi &> /dev/null";
            interval = 13;
            tooltip-format = "Gpu Temp";
            on-click = "nvidia-settings";
          };
          "bluetooth" = {
            format = "󰂰";
            format-on = "";
            format-connected = "{device_alias} 󰂱";
            format-disabled = "󰂲";
            format-off = "";
            format-no-controller = "";
            tooltip-format = "{num_connections} connected";
            tooltip-format-disabled = "Bluetooth Disabled";
            tooltip-format-connected = ''
              {num_connections} connected
              {device_enumerate}'';
            tooltip-format-enumerate-connected = "{device_alias}";
            tooltip-format-enumerate-connected-battery = "{device_alias}: {device_battery_percentage}%";
            on-click = "blueman-manager";
          };
        }
      ];
      style = ''
        /*@define-color bg #${config.stylix.base16Scheme.base00};*/
        @define-color bg rgba(24,24,37,1.0);
        /*@define-color fg #${config.stylix.base16Scheme.base0B};*/
        @define-color fg #cdd6f4;
        @define-color bg2 #${config.stylix.base16Scheme.base01};
        /*@define-color hover-color #${config.stylix.base16Scheme.base0D};*/
        @define-color hover-color #0f0;


        * {
          font-family: Noto Sans Mono;
          font-size: 12px;
          min-height: 0;
        }
        window#waybar {
          background: rgba(0, 0, 0, 0);
        }

        #custom-startmenu,
        #workspaces,
        #custom-cputemp,
        #custom-gputemp,
        #cpu,
        #idle_inhibitor,
        #custom-screen,
        #custom-picker,
        #custom-snip,
        #window,
        #custom-playerctl,
        #custom-playerlabel,
        #submap,
        #tray,
        #bluetooth,
        #clock,
        #pulseaudio,
        #network .brif,
        #network .ethernet,
        #network .wifi,
        #custom-exit,
        #custom-notification,
        #memory {
          padding: 2px 14px;
          margin: 4px 4px 0px 4px;
          background-color: @bg;
          border: none;
          border-radius: 20px;
          color: @fg;
        }

        #custom-playerlabel {
          background: transparent;
          color: @bg2;
          font-weight: bold;
        }
        #custom-snip {
          margin: 4px 0px 0px 4px;
          padding: 2px 7px 2px 14px;
          border-radius: 20px 0px 0px 20px;
        }
        #custom-picker {
          margin: 4px 4px 0px 0px;
          padding: 2px 14px 2px 7px;
          border-radius: 0px 20px 20px 0px;
        }
        #cpu,
        #custom-cputemp {
          font-weight: bold;
          color: #fc9003;
        }
        #memory {
          font-weight: bold;
          color: #41fc03;
        }
        #clock {
          font-weight: bold;
          color: #00AEEC;
        }
        #window {
          color: #C9A4F5;
        }
        #custom-screen,
        #custom-snip,
        #custom-picker {
          color: #F6CF5E;
        }
        #bluetooth {
          color: #E3939A;
        }
        #custom-notification {
          color: #B4BEFE;
        }
        #network .brif {
          color: #4dddfa;
        }
        #submap,
        #custom-playerctl {
          color: #FF0033;
        }

        #custom-startmenu:hover,
        #workspaces:hover,
        #custom-cputemp:hover,
        #custom-gputemp:hover,
        #cpu:hover,
        #idle_inhibitor:hover,
        #custom-screen:hover,
        #custom-picker:hover,
        #custom-snip:hover,
        #window:hover,
        #custom-playerctl:hover,
        #custom-playerlabel:hover,
        #submap:hover,
        #bluetooth:hover,
        #pulseaudio:hover,
        #custom-exit:hover,
        #custom-notification:hover,
        #memory:hover,
        #network .brif:hover,
        #network .ethernet:hover,
        #network .wifi:hover,
        #workspaces button:hover,
        #clock:hover {
          color: @hover-color;
        }

        button {
          box-shadow: inset 0px -3px transparent;
          border: none;
          border-radius: 0px;
        }
        button:hover {
          background: inherit;
          box-shadow: inset 0px -3px transparent;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          transition: ${betterTransition};
          background-color: transparent;
          color: @gf;
        }
        #workspaces button.active {
          font-weight: bold;
          transition: ${betterTransition};
        }
        #workspaces button.hover {
          font-weight: bold;
          transition: ${betterTransition};
        }

        tooltip {
          background: @bg;
          margin: 20px;
          padding: 15px;
          border-radius: 10px;
        }
      '';
    };
  }
