-- Hyprland 0.55 Lua Configuration
-- Migrated from hyprlang format
-- https://wiki.hypr.land/Configuring/

--------------------
--- XWayland ---
--------------------

-- unscale XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

-- host extra config
@HYPR_CONFIG@

---------------------
--- MY PROGRAMS ---
---------------------

local terminal = "kitty"

-------------------------------
--- ENVIRONMENT VARIABLES ---
-------------------------------

-- XDG Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
-- Qt Variables
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
-- Enable native Wayland support for most Electron apps
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-------------------
--- AUTOSTART ---
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("killall -q waybar;sleep .5 && waybar")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("lxqt-policykit-agent")
  hl.exec_cmd("sleep 7 && synology-drive")
end)

-----------------------
--- LOOK AND FEEL ---
-----------------------

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 5,
    border_size = 1,
    ["col.active_border"] = { colors = { "rgb(918bb9)", "rgb(8b9298)" }, angle = 45 },
    ["col.inactive_border"] = "rgb(40465e)",
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 5,
      passes = 3,
      vibrancy = 0.1696,
    },
  },
})

-- Animations
hl.config({ animations = { enabled = true } })

hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "default", style = "slidefadevert -50%" })

hl.config({
  dwindle = {
    preserve_split = true,
    force_split = 2,
  },
  master = {
    new_status = "master",
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
    initial_workspace_tracking = 0,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = false,
    focus_on_activate = true,
  },
})

---------------
--- INPUT ---
---------------

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "@XKB_OPTIONS@",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      scroll_factor = 0.8,
    },
    accel_profile = "flat",
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

-- Per-device config
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

---------------------
--- KEYBINDINGS ---
---------------------

hl.config({
  binds = {
    allow_workspace_cycles = true,
  },
})

local mainMod = "SUPER"

-- Launch applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi-launcher"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("rofi-wo"))
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("rofi-calc"))
hl.bind(mainMod .. " + backslash", hl.dsp.exec_cmd("rofimoji"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("rofi-clipboard"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("rofi -show window"))

-- Window / workspace management
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + CONTROL + SHIFT + Q", hl.dsp.exit())
-- smart toggle floating: toggle float and resize based on window class
hl.bind(mainMod .. " + SHIFT + SPACE", function()
  local w = hl.get_active_window()
  if w == nil then return end

  if w.floating then
    -- unfloat the window
    hl.dispatch(hl.dsp.window.float({ action = "unset" }))
  else
    -- determine size ratio based on window class
    local wp, hp
    if w.initialClass == "kitty" then
      wp, hp = 0.50, 0.55
    else
      wp, hp = 0.80, 0.75
    end
    -- calculate target pixel size from logical monitor dimensions
    local mon = hl.get_active_monitor()
    local scale = mon.scale or 1
    local target_w = math.floor(mon.width / scale * wp)
    local target_h = math.floor(mon.height / scale * hp)
    -- float the window (keeps its tiled size)
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
    hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h}))
    hl.dispatch(hl.dsp.window.center())
  end
end)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("screenshot"))

-- Move focus with mainMod + arrow keys / hjkl
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move windows with mainMod + SHIFT + arrow keys / hjkl
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- Move window by offset
hl.bind(mainMod .. " + CONTROL + h", hl.dsp.window.move({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + l", hl.dsp.window.move({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + k", hl.dsp.window.move({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + j", hl.dsp.window.move({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + left", hl.dsp.window.move({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.window.move({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + up", hl.dsp.window.move({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + down", hl.dsp.window.move({ x = 0, y = 50, relative = true }), { repeating = true })

-- Cycle focus
hl.bind(mainMod .. " + SPACE", hl.dsp.window.cycle_next({ next = false }), { repeating = true })
-- Bring active to top
hl.bind(mainMod .. " + CONTROL + SPACE", hl.dsp.window.alter_zorder({ mode = "top" }), { repeating = true })

-- Temp minimize one window (magic workspace trick)
hl.bind(mainMod .. " + S", function()
  hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
  hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
  hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
  hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
  hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end)

-- Move window to special workspace
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:minus" }))
hl.bind(mainMod .. " + minus", hl.dsp.workspace.toggle_special("minus"))

-- Resize and Move window submap
local resize_mode = "Resize: [   ]  Move: ctrl + [   ]"
hl.bind(mainMod .. " + R", hl.dsp.submap(resize_mode))

hl.define_submap(resize_mode, function()
  hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("CONTROL + h", hl.dsp.window.move({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("CONTROL + l", hl.dsp.window.move({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("CONTROL + k", hl.dsp.window.move({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("CONTROL + j", hl.dsp.window.move({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("CONTROL + left", hl.dsp.window.move({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("CONTROL + right", hl.dsp.window.move({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("CONTROL + up", hl.dsp.window.move({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("CONTROL + down", hl.dsp.window.move({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("c", hl.dsp.window.center())
  -- back to normal: Escape or Control+[ or q
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("CONTROL + BracketLeft", hl.dsp.submap("reset"))
  hl.bind("q", hl.dsp.submap("reset"))
end)

-- Layout
hl.bind(mainMod .. " + Q", hl.dsp.layout("togglesplit"))

-- Preselect direction
hl.bind(mainMod .. " + SHIFT + CONTROL + h", function()
  hl.dispatch(hl.dsp.layout("preselect l"))
  hl.exec_cmd('notify-send "Left Direction"')
end)
hl.bind(mainMod .. " + SHIFT + CONTROL + l", function()
  hl.dispatch(hl.dsp.layout("preselect r"))
  hl.exec_cmd('notify-send "Right Direction"')
end)
hl.bind(mainMod .. " + SHIFT + CONTROL + j", function()
  hl.dispatch(hl.dsp.layout("preselect d"))
  hl.exec_cmd('notify-send "Down Direction"')
end)
hl.bind(mainMod .. " + SHIFT + CONTROL + k", function()
  hl.dispatch(hl.dsp.layout("preselect u"))
  hl.exec_cmd('notify-send "Up Direction"')
end)

-- Group
hl.bind(mainMod .. " + w", hl.dsp.layout("togglegroup"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("changegroupactive b"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("changegroupactive f"))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wlogout"))
-- Hide waybar
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Volume Control (pulseaudio/pactl)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { repeating = true, locked = true })

-- LCD brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true, locked = true })

-- Media controls (requires playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------------
--- INPUT METHOD AUTO-SWITCHING ---
--------------------------------------

-- Per-application input method switching for fcitx5-rime
-- Default: English (input method deactivated)
-- Apps listed in `chinese_apps` will activate the input method (Chinese mode)
-- You can find the class name by running `hyprctl activewindow -j | jq .class`
local chinese_apps = {
  "wechat",
}

-- Build a lookup set for O(1) matching
local chinese_set = {}
for _, class in ipairs(chinese_apps) do
  chinese_set[class:lower()] = true
end

hl.on("window.active", function(w)
  if w == nil then return end
  local cls = (w.class or ""):lower()
  if chinese_set[cls] then
    -- Switch to Rime → Chinese mode
    hl.exec_cmd("fcitx5-remote -s rime")
  else
    -- Switch to keyboard-us → English mode (default)
    hl.exec_cmd("fcitx5-remote -s keyboard-us")
  end
end)

---------------------------------
--- WINDOWS AND WORKSPACES ---
---------------------------------

-- Ignore maximize requests from apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
hl.window_rule({
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})

hl.window_rule({ match = { class = "firefox" }, workspace = "2" })
hl.window_rule({ match = { class = "^(org.gnome.FileRoller)$" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^()$" }, stay_focused = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^()$" }, min_size = { 1, 1 } })
hl.window_rule({ match = { class = "^(thunar)$" }, opacity = "0.9 0.7" })
hl.window_rule({ match = { title = "^(Authentication Required)$" }, float = true })
hl.window_rule({ match = { title = "^(Open Folder)$" }, float = true })

-- Float window with title "FloatWindow"
hl.window_rule({ match = { title = "^(FloatWindow)$" }, float = true })
hl.window_rule({ match = { title = "^(FloatWindow)$" }, size = { "monitor_w*0.7", "monitor_h*0.7" } })
hl.window_rule({ match = { title = "^(FloatWindow)$", float = true }, center = true })

-- KeePassXC
hl.window_rule({
  match = { class = "org.keepassxc.KeePassXC" },
  float = true,
  size = { "monitor_w*0.6", "monitor_h*0.8" },
  center = true,
})
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("keepassxc"))

-- Telegram desktop
hl.window_rule({ match = { initial_class = "org.telegram.desktop" }, float = true })
hl.window_rule({ match = { initial_class = "org.telegram.desktop", float = true }, center = true })
hl.window_rule({ match = { initial_class = "org.telegram.desktop", float = true }, border_size = 0 })

-- Discord
hl.window_rule({ match = { class = "discord" }, float = true })
hl.window_rule({ match = { class = "discord" }, border_size = 0 })

-- WeChat
hl.window_rule({ match = { initial_title = "Weixin" }, border_size = 0, float = true, center = true })
hl.window_rule({ match = { class = "wechat", title = "^(Chat History for.*)$" }, float = true })
hl.window_rule({
  match = { class = "wechat", title = "^(Photos and Videos|Favorites)$" },
  float = true,
  size = { "monitor_w*0.6", "monitor_h*0.8" },
  center = true,
})
hl.window_rule({
  match = { class = "wechat", title = "^(Open)$" },
  border_size = 0,
  move = "onscreen cursor",
  no_anim = true,
  center = true,
  pin = true,
})
-- Move all wechat windows to special workspace
hl.window_rule({ match = { initial_class = "wechat" }, workspace = "special:wechat" })
hl.window_rule({ match = { initial_title = "微信" }, workspace = "special:wechat" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.workspace.toggle_special("wechat"))

-- Fix IntelliJ IDEs
-- https://github.com/hyprwm/Hyprland/issues/3450
hl.window_rule({
  match = { class = "^(jetbrains-.*)$", title = "^(splash)$", float = true },
  center = true, no_focus = true, border_size = 0,
})
hl.window_rule({
  match = { class = "^(jetbrains-.*)$", title = "^( )$", float = true },
  center = true, stay_focused = true, border_size = 0,
})
hl.window_rule({
  match = { class = "^(jetbrains-.*)$", title = "^(win.*)$", float = true },
  no_focus = true,
})
