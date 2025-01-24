{ pkgs, lib, username, host, config, inputs, ... }@args:

let inherit (import ../../hosts/${host}/variables.nix) monitor xkbOptions;
in with lib; {

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
    # Wayland clipboard utilities (wl-copy and wl-paste)
    wl-clipboard
    # Wayland event viewer debug tool
    wev
    # Xorg tools
    xorg.xprop
    # control device brightness
    brightnessctl
    # An archive manager utility for thunar
    file-roller
    # GTK settings editor
    nwg-look
  ];

  # Enable Ozone Wayland support chromium and Electron based applications
  # This allows these applications to run without Xwayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    extraConfig = ''
      # Hyprland config file

      # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
      # https://wiki.hyprland.org/Configuring/

      ################
      ### XWayland ###
      ################

      # unscale XWayland
      xwayland {
        force_zero_scaling = true
      }

      # toolkit-specific scale
      env = GDK_SCALE,2
      env = XCURSOR_SIZE,22


      ################
      ### MONITORS ###
      ################

      # See https://wiki.hyprland.org/Configuring/Monitors/
      # monitor=,preferred,auto,auto
      ${monitor}

      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      $terminal = kitty


      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      # XDG Specifications
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_TYPE,wayland
      env = XDG_SESSION_DESKTOP,Hyprland
      # Qt Variables
      env = QT_AUTO_SCREEN_SCALE_FACTOR,1          # enables automatic scaling, based on the monitor’s pixel density
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1  # Disables window decorations on Qt applications
      env = QT_QPA_PLATFORM,wayland;xcb            # Qt: Use wayland if available, fall back to x11 if not.
      env = GDK_BACKEND,wayland,x11                # GTK: Use wayland if available. If not: try x11, then any other GDK backend.
      env = SDL_VIDEODRIVER,wayland                # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
      env = CLUTTER_BACKEND,wayland                # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend


      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:

      exec-once = dbus-update-activation-environment --systemd --all
      exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = killall -q waybar;sleep .5 && waybar
      exec-once = nm-applet --indicator
      exec-once = lxqt-policykit-agent
      exec-once = sleep 7 && synology-drive


      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general {
          gaps_in = 3
          gaps_out = 8

          border_size = 1

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgb(${config.stylix.base16Scheme.base08}) rgb(${config.stylix.base16Scheme.base0C}) 45deg
          # col.inactive_border = rgb(${config.stylix.base16Scheme.base01})

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = true

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false

          layout = dwindle
      }

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration {
          rounding = 10

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 1.0

          shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 5
              passes = 3

              vibrancy = 0.1696
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations {
          enabled = yes, please :)

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = wind, 0.05, 0.9, 0.1, 1.05
          bezier = winIn, 0.1, 1.1, 0.1, 1.1
          bezier = winOut, 0.3, -0.3, 0, 1
          bezier = liner, 1, 1, 1, 1
          animation = windows, 1, 6, wind, slide
          animation = windowsIn, 1, 6, winIn, slide
          animation = windowsOut, 1, 5, winOut, slide
          animation = windowsMove, 1, 5, wind, slide
          animation = border, 1, 1, liner
          animation = fade, 1, 10, default
          animation = workspaces, 1, 5, wind
      }

      # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
      # "Smart gaps" / "No gaps when only"
      # uncomment all if you wish to use that.
      # workspace = w[tv1], gapsout:0, gapsin:0
      # workspace = f[1], gapsout:0, gapsin:0
      # windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
      # windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
      # windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
      # windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # You probably want this
          force_split = 2 # always split to the right (new = right or bottom)
      }

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc {
          force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
          initial_workspace_tracking = 0 # if enabled, windows will open on the workspace they were invoked on. 0 - disabled, 1 - single-shot, 2 - persistent (all children too)
          mouse_move_enables_dpms = true # If DPMS is set to off, wake up the monitors if the mouse moves.
          key_press_enables_dpms = false # If DPMS is set to off, wake up the monitors if a key is pressed.
          focus_on_activate = true # focus an app that requests to be focused (an activate request)
      }


      #############
      ### INPUT ###
      #############

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options = ${xkbOptions}
          kb_rules =

          follow_mouse = 1

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          touchpad {
              natural_scroll = true
              disable_while_typing = true
              scroll_factor = 0.8
          }
          sensitivity = 0 # Sets the mouse input sensitivity, Value is clamped to the range -1.0 to 1.0.
          accel_profile = flat
      }

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures {
          workspace_swipe = true
          workspace_swipe_fingers = 3
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device {
          name = epic-mouse-v1
          sensitivity = -0.5
      }


      ###################
      ### KEYBINDINGS ###
      ###################

      binds {
      allow_workspace_cycles = true
      }

      # See https://wiki.hyprland.org/Configuring/Keywords/
      $mainMod = SUPER # Sets "Windows" key as main modifier

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, Return, exec, $terminal
      bind = $mainMod, D, exec, rofi-launcher
      bind = $mainMod, X, exec, rofi-wo
      bind = $mainMod, equal, exec, rofi-calc
      bind = $mainMod SHIFT, V, exec, rofi-clipboard
      bind = $mainMod, T, exec, rofi -show window
      bind = $mainMod, Tab, workspace, previous
      bind = $mainMod SHIFT, Q, killactive,
      bind = $mainMod CONTROL SHIFT, Q, exit,
      # bind = $mainMod SHIFT, SPACE, togglefloating,
      # use smart togglefloating script
      bind = $mainMod SHIFT, SPACE, exec, hypr-smarttf
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod SHIFT, F, fullscreen,
      bind = $mainMod SHIFT, A, exec, screenshot

      # Move focus with mainMod + arrow keys / hjkl
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Move focus windows with mainMod + SHIFT + arrow keys / hjkl
      bind = $mainMod SHIFT, H, movewindow, l
      bind = $mainMod SHIFT, L, movewindow, r
      bind = $mainMod SHIFT, K, movewindow, u
      bind = $mainMod SHIFT, J, movewindow, d
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d
      # move window
      binde = $mainMod CONTROL, h, moveactive, -50 0
      binde = $mainMod CONTROL, l, moveactive, 50 0
      binde = $mainMod CONTROL, k, moveactive, 0 -50
      binde = $mainMod CONTROL, j, moveactive, 0 50
      binde = $mainMod CONTROL, left, moveactive, -50 0
      binde = $mainMod CONTROL, right, moveactive, 50 0
      binde = $mainMod CONTROL, up, moveactive, 0 -50
      binde = $mainMod CONTROL, down, moveactive, 0 50
      # change focus
      binde = $mainMod, SPACE, cyclenext, prev
      # bring activate to top
      binde = $mainMod CONTROL, SPACE, alterzorder, top

      # Resize and Move window submap
      bind = $mainMod, R, exec, hyprctl dispatch submap resize; notify-send "Enter Window Change Mode"
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      binde = , l, resizeactive, 10 0
      binde = , h, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10
      binde = CONTROL, h, moveactive, -10 0
      binde = CONTROL, l, moveactive, 10 0
      binde = CONTROL, k, moveactive, 0 -10
      binde = CONTROL, j, moveactive, 0 10
      binde = CONTROL, left, moveactive, -10 0
      binde = CONTROL, right, moveactive, 10 0
      binde = CONTROL, up, moveactive, 0 -10
      binde = CONTROL, down, moveactive, 0 10
      bind = , c, centerwindow,
      # back to normal: `Escape` or `Control+[`
      bind = , escape, exec, hyprctl dispatch submap reset; notify-send "Exit Window Change Mode"
      bind = CONTROL, BracketLeft, exec, hyprctl dispatch submap reset; notify-send "Exit Window Change Mode"
      submap = reset

      bind = $mainMod, Q, layoutmsg, togglesplit
      bind = $mainMod SHIFT CONTROL, h, exec, hyprctl dispatch layoutmsg preselect l; notify-send "Left Direction"
      bind = $mainMod SHIFT CONTROL, l, exec, hyprctl dispatch layoutmsg preselect r; notify-send "Right Direction"
      bind = $mainMod SHIFT CONTROL, j, exec, hyprctl dispatch layoutmsg preselect d; notify-send "Down Direction"
      bind = $mainMod SHIFT CONTROL, k, exec, hyprctl dispatch layoutmsg preselect u; notify-send "Up Direction"

      bind = $mainMod, w, togglegroup
      bind = $mainMod SHIFT, H, changegroupactive, b
      bind = $mainMod SHIFT, L, changegroupactive, f

      bind = $mainMod SHIFT, E, exec, wlogout


      # Volume Control
      # if you use pipewire service
      # bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      # bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      # bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      # bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      # if you use pulseaudio use pactl instead
      bindel = ,XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
      bindel = ,XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
      bindel = ,XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
      # LCD brightness
      bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-

      # Requires playerctl
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      # Ignore maximize requests from apps. You'll probably like this.
      windowrulev2 = suppressevent maximize, class:.*

      # Fix some dragging issues with XWayland
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

      # windowrule = float, nm-connection-editor|blueman-manager
      windowrule = workspace 2, firefox
      windowrule = float, ^(org.gnome.FileRoller)$
      # windowrulev2 = float, class:^(kitty)$, title:^(kitty)$
      # windowrulev2 = size 60% 70%, initialClass:^(kitty)$
      windowrulev2 = float, class:org.pulseaudio.pavucontrol
      windowrulev2 = stayfocused, title:^()$,class:^(steam)$
      windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
      windowrulev2 = opacity 0.9 0.7, class:^(thunar)$
      windowrulev2 = float, title:^(Authentication Required)$
      windowrulev2 = float, title:^(Open Folder)$

      # keepassxc auto start and move to special workspace (scratchpad)
      exec-once = [workspace special:keepassxc silent] keepassxc
      windowrulev2 = float, class:org.keepassxc.KeePassXC
      windowrulev2 = center, floating:1, class:org.keepassxc.KeePassXC
      windowrulev2 = workspace special:keepassxc, class:org.keepassxc.KeePassXC
      bind = $mainMod SHIFT, P, exec, hyprctl dispatch togglespecialworkspace keepassxc && hyprctl dispatch centerwindow

      # wechat
      windowrulev2 = noborder, initialTitle:微信
      windowrulev2 = float, initialTitle:微信
      windowrulev2 = centerwindow, initialTitle:微信
      # 发送文件
      windowrulev2 = pin, class:^(wechat)$, title:^(Open)$
      # 点击出来的框框
      windowrulev2 = noborder, title:^(wechat)$, class:^(wechat)$
      windowrulev2 = noanim, title:^(wechat)$, class:^(wechat)$
      windowrulev2 = pin, title:^(wechat)$, class:^(wechat)$
      windowrulev2 = move onscreen cursor, title:^(wechat)$, class:^(wechat)$
      # 聊天记录
      windowrulev2 = float, title:^(.*聊天记录.*)$, class:^(wechat)$
      # 图片预览
      windowrulev2 = float, title:^(预览)$, class:^(wechat)$
      windowrulev2 = centerwindow, title:^(预览)$, class:^(wechat)$
      # 公众号
      windowrulev2 = float, title:^(公众号)$, class:^()$
      # move all to special workspace
      windowrulev2 = workspace special:wechat, initialClass:wechat
      windowrulev2 = workspace special:wechat, initialTitle:微信
      bind = $mainMod SHIFT, W, togglespecialworkspace, wechat
    '';
  };
}
