-- IME auto-switch module for Squirrel (鼠须管)
--
-- Sends Rime-defined hotkeys to toggle ascii_mode *within* Squirrel:
--   Ctrl+Alt+Shift+E  →  set_option: ascii_mode   (English)
--   Ctrl+Alt+Shift+C  →  unset_option: ascii_mode  (Chinese)
--
-- Uses hs.window.filter to detect app focus changes.

------------------------------------------------------------
-- Configuration: app bundle identifier → desired mode
------------------------------------------------------------
-- "english" = send Ctrl+Alt+Shift+E on focus
-- "chinese" = send Ctrl+Alt+Shift+C on focus
-- Apps not listed here will NOT be touched.

local app2mode = {
	["net.kovidgoyal.kitty"] = "english",
	["com.github.wez.wezterm"] = "english",
	["com.mitchellh.ghostty"] = "english",
	["com.googlecode.iterm2"] = "english",
	["com.google.Chrome"] = "english",
	["org.mozilla.firefox"] = "english",
	["com.apple.Safari"] = "english",
	["com.raycast.macos"] = "english",
	["com.tencent.xinWeChat"] = "chinese",
	["com.electron.lark"] = "chinese",
}

------------------------------------------------------------
-- Send the Rime hotkey to switch ascii_mode
------------------------------------------------------------
local function switchToEnglish()
	hs.eventtap.keyStroke({ "ctrl", "alt", "shift" }, "e")
end

local function switchToChinese()
	hs.eventtap.keyStroke({ "ctrl", "alt", "shift" }, "c")
end

-- Global to prevent garbage collection
imeAppWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
	if eventType ~= hs.application.watcher.activated then
		return
	end
	if not appObject then
		return
	end

	local bundleID = appObject:bundleID()
	if not bundleID then
		return
	end

	local mode = app2mode[bundleID]
	if not mode then
		return
	end

	hs.timer.doAfter(0.15, function()
		if mode == "english" then
			switchToEnglish()
		elseif mode == "chinese" then
			switchToChinese()
		else
			switchToEnglish()
		end
	end)
end)
imeAppWatcher:start()

------------------------------------------------------------
-- Helper: show current app info (Ctrl+Cmd+.)
------------------------------------------------------------
hs.hotkey.bind({ "ctrl", "cmd" }, ".", function()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No focused window")
		return
	end

	local app = win:application()
	local bundleID = app:bundleID() or "N/A"
	local data = "App path:        "
		.. (app:path() or "N/A")
		.. "\n"
		.. "App name:        "
		.. (app:name() or "N/A")
		.. "\n"
		.. "Bundle ID:       "
		.. bundleID
		.. "\n"
		.. "IM source id:    "
		.. hs.keycodes.currentSourceID()
	print("\n" .. data)
	hs.pasteboard.setContents(bundleID)
	hs.alert.show(data)
end)

print("[ime] auto switch moudle started")
