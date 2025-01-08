{ pkgs, lib, username, host, config, inputs, ... }@args:

let
  inherit (import ../../hosts/${host}/variables.nix)
    browser terminal extraMonitorSettings keyboardLayout wallpaper;
in with lib; {

  imports = [
    ./wlogout
    ./hypridel.nix
    (import ./hyprlock.nix { inherit username wallpaper; })
    ./waybar.nix
    ./swaync.nix
  ];

  # link wallpapers into home Pictures directory
  home.file."Pictures/Wallpapers" = {
    source = ../../wallpapers;
    recursive = true;
  };

  # GTK+ 2/3 applications themes config
  gtk = {
    enable = true;
    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    theme = {
      name = "WhiteSur-Dark-solid";
      package = pkgs.whitesur-gtk-theme;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    gtk3 = {
      # FIXME: Bookmarks in the sidebar of the GTK file browser
      bookmarks = [
        "file:///home/fython/Downloads Downloads"
        "file:///home/fython/Documents Documents"
        "file:///home/fython/SynologyDrive Drive"
      ];
    };
  };
  # QT application style
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  home.packages = with pkgs; [
    # Wayland clipboard utilities (wl-copy and wl-paste)
    wl-clipboard
    # Wayland event viewer debug tool
    wev
    # Xorg tools
    xorg.xprop
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig = ''
      # This is an example Hyprland config file.
      # Refer to the wiki for more information.
      # https://wiki.hyprland.org/Configuring/

      # Please note not all available settings / options are set here.
      # For a full list, see the wiki

      # You can split this configuration into multiple files
      # Create your files separately and then link them to this file like this:
      # source = ~/.config/hypr/myColors.conf


      ################
      ### MONITORS ###
      ################

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=,preferred,3840x2160@60,2

      # unscale XWayland
      xwayland {
        force_zero_scaling = true
      }

      # toolkit-specific scale
      env = GDK_SCALE,2
      env = XCURSOR_SIZE,22


      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      $terminal = kitty
      $fileManager = dolphin
      $menu = wofi --show drun


      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:

      # exec-once = $terminal
      # exec-once = nm-applet &
      # exec-once = waybar & hyprpaper & firefox
      exec-once = killall -q waybar;sleep .5 && waybar


      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      # env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24


      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general {
          gaps_in = 5
          gaps_out = 20

          border_size = 2

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false

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
              size = 3
              passes = 1

              vibrancy = 0.1696
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations {
          enabled = yes, please :)

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = easeOutQuint,0.23,1,0.32,1
          bezier = easeInOutCubic,0.65,0.05,0.36,1
          bezier = linear,0,0,1,1
          bezier = almostLinear,0.5,0.5,0.75,1.0
          bezier = quick,0.15,0,0.1,1

          animation = global, 1, 10, default
          animation = border, 1, 5.39, easeOutQuint
          animation = windows, 1, 4.79, easeOutQuint
          animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
          animation = windowsOut, 1, 1.49, linear, popin 87%
          animation = fadeIn, 1, 1.73, almostLinear
          animation = fadeOut, 1, 1.46, almostLinear
          animation = fade, 1, 3.03, quick
          animation = layers, 1, 3.81, easeOutQuint
          animation = layersIn, 1, 4, easeOutQuint, fade
          animation = layersOut, 1, 1.5, linear, fade
          animation = fadeLayersIn, 1, 1.79, almostLinear
          animation = fadeLayersOut, 1, 1.39, almostLinear
          animation = workspaces, 1, 1.94, almostLinear, fade
          animation = workspacesIn, 1, 1.21, almostLinear, fade
          animation = workspacesOut, 1, 1.94, almostLinear, fade
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
      }


      #############
      ### INPUT ###
      #############

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          touchpad {
              natural_scroll = false
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures {
          workspace_swipe = false
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
      bind = $mainMod, Tab, workspace, previous
      bind = $mainMod SHIFT, Q, killactive,
      # exit hyprland
      bind = $mainMod CONTROL SHIFT, Q, exit,
      # bind = $mainMod, E, exec, $fileManager
      bind = $mainMod SHIFT, SPACE, togglefloating,
      bind = $mainMod, R, exec, $menu
      bind = $mainMod, P, pseudo, # dwindle
      # bind = $mainMod, J, togglesplit, # dwindle

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


      # Laptop multimedia keys for volume and LCD brightness
      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
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

      # Example windowrule v1
      # windowrule = float, ^(kitty)$

      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

      # Ignore maximize requests from apps. You'll probably like this.
      windowrulev2 = suppressevent maximize, class:.*

      # Fix some dragging issues with XWayland
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

      # windowrule = float, nm-connection-editor|blueman-manager
      windowrule = workspace 2, firefox
      windowrulev2 = float, class:org.pulseaudio.pavucontrol

      # keepassxc auto start and move to special workspace (scratchpad)
      exec-once = [workspace special:keepassxc] keepassxc
      windowrulev2 = float, class:org.keepassxc.KeePassXC
      windowrulev2 = size 40% 40%, class:org.keepassxc.KeePassXC
      windowrulev2 = workspace special:keepassxc, class:org.keepassxc.KeePassXC
      bind = $mainMod SHIFT, P, togglespecialworkspace, keepassxc

      # wechat
      windowrulev2 = float, initialTitle:微信
      windowrulev2 = noborder, initialTitle:微信
      windowrulev2 = float, initialClass:wechat
      windowrulev2 = noborder, initialClass:wechat
      windowrulev2 = centerwindow, initialTitle:微信
      windowrulev2 = workspace special:wechat, initialClass:wechat
      windowrulev2 = workspace special:wechat, initialClass:微信
      bind = $mainMod SHIFT, W, togglespecialworkspace, wechat

    '';
    # extraConfig =
    #   let
    #     modifier = "SUPER";
    #   in
    #   concatStrings [
    #     ''
    #       env = NIXOS_OZONE_WL, 1
    #       env = NIXPKGS_ALLOW_UNFREE, 1
    #       env = XDG_CURRENT_DESKTOP, Hyprland
    #       env = XDG_SESSION_TYPE, wayland
    #       env = XDG_SESSION_DESKTOP, Hyprland
    #       env = GDK_BACKEND, wayland, x11
    #       env = CLUTTER_BACKEND, wayland
    #       env = QT_QPA_PLATFORM=wayland;xcb
    #       env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
    #       env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
    #       env = SDL_VIDEODRIVER, x11
    #       env = MOZ_ENABLE_WAYLAND, 1
    #       exec-once = dbus-update-activation-environment --systemd --all
    #       exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    #       exec-once = killall -q swww;sleep .5 && swww init
    #       exec-once = killall -q waybar;sleep .5 && waybar
    #       exec-once = killall -q swaync;sleep .5 && swaync
    #       exec-once = nm-applet --indicator
    #       exec-once = lxqt-policykit-agent
    #       exec-once = sleep 1.5 && swww img /home/${username}/Pictures/Wallpapers/beautifulmountainscape.jpg
    #       monitor=,preferred,auto,1
    #       ${extraMonitorSettings}
    #       general {
    #         gaps_in = 6
    #         gaps_out = 8
    #         border_size = 2
    #         layout = dwindle
    #         resize_on_border = true
    #         col.active_border = rgb(${config.stylix.base16Scheme.base08}) rgb(${config.stylix.base16Scheme.base0C}) 45deg
    #         col.inactive_border = rgb(${config.stylix.base16Scheme.base01})
    #       }
    #       input {
    #         kb_layout = ${keyboardLayout}
    #         kb_options = grp:alt_shift_toggle
    #         kb_options = caps:super
    #         follow_mouse = 1
    #         touchpad {
    #           natural_scroll = true
    #           disable_while_typing = true
    #           scroll_factor = 0.8
    #         }
    #         sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    #         accel_profile = flat
    #       }
    #       windowrule = noborder,^(wofi)$
    #       windowrule = center,^(wofi)$
    #       windowrule = center,^(steam)$
    #       windowrule = float, nm-connection-editor|blueman-manager
    #       windowrule = float, swayimg|vlc|Viewnior|pavucontrol
    #       windowrule = float, nwg-look|qt5ct|mpv
    #       windowrule = float, zoom
    #       windowrulev2 = stayfocused, title:^()$,class:^(steam)$
    #       windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
    #       windowrulev2 = opacity 0.9 0.7, class:^(Brave)$
    #       windowrulev2 = opacity 0.9 0.7, class:^(thunar)$
    #       gestures {
    #         workspace_swipe = true
    #         workspace_swipe_fingers = 3
    #       }
    #       misc {
    #         initial_workspace_tracking = 0
    #         mouse_move_enables_dpms = true
    #         key_press_enables_dpms = false
    #       }
    #       animations {
    #         enabled = yes
    #         bezier = wind, 0.05, 0.9, 0.1, 1.05
    #         bezier = winIn, 0.1, 1.1, 0.1, 1.1
    #         bezier = winOut, 0.3, -0.3, 0, 1
    #         bezier = liner, 1, 1, 1, 1
    #         animation = windows, 1, 6, wind, slide
    #         animation = windowsIn, 1, 6, winIn, slide
    #         animation = windowsOut, 1, 5, winOut, slide
    #         animation = windowsMove, 1, 5, wind, slide
    #         animation = border, 1, 1, liner
    #         animation = fade, 1, 10, default
    #         animation = workspaces, 1, 5, wind
    #       }
    #       decoration {
    #         rounding = 10
    #         drop_shadow = true
    #         shadow_range = 4
    #         shadow_render_power = 3
    #         col.shadow = rgba(1a1a1aee)
    #         blur {
    #             enabled = true
    #             size = 5
    #             passes = 3
    #             new_optimizations = on
    #             ignore_opacity = off
    #         }
    #       }
    #       plugin {
    #         hyprtrails {
    #         }
    #       }
    #       dwindle {
    #         pseudotile = true
    #         preserve_split = true
    #       }
    #       bind = ${modifier},Return,exec,${terminal}
    #       bind = ${modifier}SHIFT,Return,exec,rofi-launcher
    #       bind = ${modifier}SHIFT,W,exec,web-search
    #       bind = ${modifier}ALT,W,exec,wallsetter
    #       bind = ${modifier}SHIFT,N,exec,swaync-client -rs
    #       bind = ${modifier},W,exec,${browser}
    #       bind = ${modifier},E,exec,emopicker9000
    #       bind = ${modifier},S,exec,screenshootin
    #       bind = ${modifier},D,exec,discord
    #       bind = ${modifier},O,exec,obs
    #       bind = ${modifier},C,exec,hyprpicker -a
    #       bind = ${modifier},G,exec,gimp
    #       bind = ${modifier}SHIFT,G,exec,godot4
    #       bind = ${modifier},T,exec,thunar
    #       bind = ${modifier},M,exec,spotify
    #       bind = ${modifier},Q,killactive,
    #       bind = ${modifier},P,pseudo,
    #       bind = ${modifier}SHIFT,I,togglesplit,
    #       bind = ${modifier},F,fullscreen,
    #       bind = ${modifier}SHIFT,F,togglefloating,
    #       bind = ${modifier}SHIFT,C,exit,
    #       bind = ${modifier}SHIFT,left,movewindow,l
    #       bind = ${modifier}SHIFT,right,movewindow,r
    #       bind = ${modifier}SHIFT,up,movewindow,u
    #       bind = ${modifier}SHIFT,down,movewindow,d
    #       bind = ${modifier}SHIFT,h,movewindow,l
    #       bind = ${modifier}SHIFT,l,movewindow,r
    #       bind = ${modifier}SHIFT,k,movewindow,u
    #       bind = ${modifier}SHIFT,j,movewindow,d
    #       bind = ${modifier},left,movefocus,l
    #       bind = ${modifier},right,movefocus,r
    #       bind = ${modifier},up,movefocus,u
    #       bind = ${modifier},down,movefocus,d
    #       bind = ${modifier},h,movefocus,l
    #       bind = ${modifier},l,movefocus,r
    #       bind = ${modifier},k,movefocus,u
    #       bind = ${modifier},j,movefocus,d
    #       bind = ${modifier},1,workspace,1
    #       bind = ${modifier},2,workspace,2
    #       bind = ${modifier},3,workspace,3
    #       bind = ${modifier},4,workspace,4
    #       bind = ${modifier},5,workspace,5
    #       bind = ${modifier},6,workspace,6
    #       bind = ${modifier},7,workspace,7
    #       bind = ${modifier},8,workspace,8
    #       bind = ${modifier},9,workspace,9
    #       bind = ${modifier},0,workspace,10
    #       bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
    #       bind = ${modifier},SPACE,togglespecialworkspace
    #       bind = ${modifier}SHIFT,1,movetoworkspace,1
    #       bind = ${modifier}SHIFT,2,movetoworkspace,2
    #       bind = ${modifier}SHIFT,3,movetoworkspace,3
    #       bind = ${modifier}SHIFT,4,movetoworkspace,4
    #       bind = ${modifier}SHIFT,5,movetoworkspace,5
    #       bind = ${modifier}SHIFT,6,movetoworkspace,6
    #       bind = ${modifier}SHIFT,7,movetoworkspace,7
    #       bind = ${modifier}SHIFT,8,movetoworkspace,8
    #       bind = ${modifier}SHIFT,9,movetoworkspace,9
    #       bind = ${modifier}SHIFT,0,movetoworkspace,10
    #       bind = ${modifier}CONTROL,right,workspace,e+1
    #       bind = ${modifier}CONTROL,left,workspace,e-1
    #       bind = ${modifier},mouse_down,workspace, e+1
    #       bind = ${modifier},mouse_up,workspace, e-1
    #       bindm = ${modifier},mouse:272,movewindow
    #       bindm = ${modifier},mouse:273,resizewindow
    #       bind = ALT,Tab,cyclenext
    #       bind = ALT,Tab,bringactivetotop
    #       bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    #       bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    #       binde = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    #       bind = ,XF86AudioPlay, exec, playerctl play-pause
    #       bind = ,XF86AudioPause, exec, playerctl play-pause
    #       bind = ,XF86AudioNext, exec, playerctl next
    #       bind = ,XF86AudioPrev, exec, playerctl previous
    #       bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
    #       bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%
    #     ''
    #   ];
  };
}
