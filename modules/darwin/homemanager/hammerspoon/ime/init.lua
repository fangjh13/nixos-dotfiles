local function switch2IME(ime)
	if hs.keycodes.currentSourceID() ~= ime then
		hs.keycodes.currentSourceID(ime)
	end
end

local function Chinese()
	-- local ime = "com.apple.inputmethod.SCIM.Shuangpin"
	-- local ime = "com.apple.inputmethod.SCIM.WBX"  -- 五笔
	local ime = "im.rime.inputmethod.Squirrel.Hans" -- 鼠鬚管
	switch2IME(ime)
end

local function English()
	local ime = "com.apple.keylayout.ABC"
	switch2IME(ime)
end

-- app to expected ime config
local app2Ime = {
	["com.googlecode.iterm2"] = "English",
	["com.apple.dt.Xcode"] = "English",
	["com.github.wez.wezterm"] = "English",
	["com.mitchellh.ghostty"] = "English",
	["net.kovidgoyal.kitty"] = "English",
	["com.microsoft.VSCode"] = "English",
	["com.jetbrains.pycharm"] = "English",
	["org.mozilla.firefox"] = "English",
	["com.apple.Safari"] = "English",
	["com.google.Chrome"] = "English",
	["com.apple.finder"] = "English",
	["com.apple.systempreferences"] = "English",
	["com.raycast.macos"] = "English",
	["com.alibaba.DingTalkMac"] = "Chinese",
	["com.tencent.xinWeChat"] = "Chinese",
	["com.electron.lark"] = "Chinese",
}

function updateFocusAppInputMethodForApp(appObject)
	if not appObject then
		return
	end

	local bundleID = appObject:bundleID()
	if not bundleID then
		return
	end

	local ime = app2Ime[bundleID]
	if not ime then
		return
	end

	if ime == "English" then
		English()
	elseif ime == "Chinese" then
		Chinese()
	end
end

-- helper hotkey to figure out the app path and name of current focused window
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
	hs.alert.show(data)
	hs.pasteboard.setContents(bundleID)
end)

-- Handle cursor focus and application's screen manage.
function applicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		updateFocusAppInputMethodForApp(appObject)
	end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

print("[ime] auto switch moudle started")
