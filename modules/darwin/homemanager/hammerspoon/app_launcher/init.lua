launcherHotkey = { "option" }

applist = {
	{ shortcut = "1", appname = "Finder" },
	{ shortcut = "2", appname = "Google Chrome" },
	{ shortcut = "3", appname = "kitty" },
}

hs.fnutils.each(applist, function(entry)
	hs.hotkey.bind(launcherHotkey, entry.shortcut, entry.appname, function()
		-- 1. Tell macOS to launch or focus the app normally
		hs.application.launchOrFocus(entry.appname)

		-- 2. Grab the app object to fix the fullscreen/Space bug
		local app = hs.application.get(entry.appname)

		-- 3. If the app is running, explicitly focus its main window.
		-- (If it's launching for the first time, 'app' might be nil, which is fine
		-- because macOS automatically switches spaces for newly opened apps).
		if app then
			local win = app:mainWindow()
			if win then
				win:focus()
			end
		end

		hs.alert.closeAll()
	end)
end)

-- use `command+shift+p` open/hide keepassxc
hs.hotkey.bind({ "cmd", "shift" }, "p", function()
	local bundleID = "org.keepassxc.keepassxc"
	local frontmostApp = hs.application.frontmostApplication()
	if frontmostApp and frontmostApp:bundleID() == bundleID then
		hs.eventtap.keyStroke({ "cmd" }, "h")
	else
		hs.application.launchOrFocusByBundleID(bundleID)
	end
end)
