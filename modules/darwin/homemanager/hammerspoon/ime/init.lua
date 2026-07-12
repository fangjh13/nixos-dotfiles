local log = hs.logger.new("ime", "warning")

local function switch2IME(ime)
	local currentIme = hs.keycodes.currentSourceID()
	if currentIme == ime then
		return true
	end

	local switched = hs.keycodes.currentSourceID(ime)
	if not switched then
		log.ef("Failed to switch input source from %s to %s", tostring(currentIme), ime)
	end
	return switched
end

local function Chinese()
	-- local ime = "com.apple.inputmethod.SCIM.Shuangpin"
	-- local ime = "com.apple.inputmethod.SCIM.WBX"  -- 五笔
	local ime = "im.rime.inputmethod.Squirrel.Hans" -- 鼠鬚管
	return switch2IME(ime)
end

local function English()
	local ime = "com.apple.keylayout.ABC"
	return switch2IME(ime)
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

-- Resolve the actual system-wide keyboard focus through Accessibility. Unlike
-- frontmostApplication(), this also sees non-activating panels and agent apps.
local systemWideElement = hs.axuielement.systemWideElement()
local lastFocusedElementPID

local function updateFromSystemFocusedElement(force)
	local focusedElement = systemWideElement:attributeValue("AXFocusedUIElement")
	local pid = focusedElement and focusedElement:pid()
	if not pid or (not force and pid == lastFocusedElementPID) then
		return
	end

	lastFocusedElementPID = pid
	updateFocusAppInputMethodForApp(hs.application.applicationForPID(pid))
end

-- helper hotkey to figure out the app path and name of current focused window
hs.hotkey.bind({ "ctrl", "cmd" }, ".", function()
	local focusedElement = systemWideElement:attributeValue("AXFocusedUIElement")
	local pid = focusedElement and focusedElement:pid()
	local app = pid and hs.application.applicationForPID(pid)
	if not app then
		hs.alert.show("No focused application")
		return
	end

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

-- Watch focus changes inside configured applications. This catches agent and
-- launcher panels that do not become the normal frontmost application.
local uiElementWatchers = {}
local uiWatcherEvents = hs.uielement.watcher

local function startUIElementWatcher(appObject)
	if not appObject then
		return
	end

	local bundleID = appObject:bundleID()
	local pid = appObject:pid()
	if not bundleID or not app2Ime[bundleID] or not pid or uiElementWatchers[pid] then
		return
	end

	local watcher
	local created, createError = pcall(function()
		watcher = appObject:newWatcher(function()
			updateFromSystemFocusedElement(true)
		end)
	end)
	if not created or not watcher then
		log.ef("Failed to create UI focus watcher for %s: %s", bundleID, tostring(createError))
		return
	end

	local started, err = pcall(function()
		watcher:start({
			uiWatcherEvents.focusedElementChanged,
			uiWatcherEvents.focusedWindowChanged,
			uiWatcherEvents.applicationShown,
		})
	end)
	if not started then
		log.ef("Failed to start UI focus watcher for %s: %s", bundleID, tostring(err))
		return
	end

	uiElementWatchers[pid] = watcher
end

-- Handle application lifecycle and normal application activation.
function applicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		updateFocusAppInputMethodForApp(appObject)
	elseif eventType == hs.application.watcher.launched then
		startUIElementWatcher(appObject)
	elseif eventType == hs.application.watcher.terminated and appObject then
		uiElementWatchers[appObject:pid()] = nil
	end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

for _, appObject in ipairs(hs.application.runningApplications()) do
	startUIElementWatcher(appObject)
end

-- Some launcher/agent apps (notably Raycast) show a focused panel without a
-- reliable application "activated" event. Watch actual window focus as well.
windowFocusWatcher = hs.window.filter.new(true)
windowFocusWatcher:subscribe(hs.window.filter.windowFocused, function(win)
	if not win then
		return
	end

	updateFocusAppInputMethodForApp(win:application())
end)

-- Generic fallback for applications that emit no usable focus notification.
focusedElementPoller = hs.timer.doEvery(0.1, updateFromSystemFocusedElement)
updateFromSystemFocusedElement()

print("[ime] auto switch module started")
