-- =====================================================================
-- Auto Max Brightness Control
-- =====================================================================
-- Automatically sets display brightness to maximum (100%) when:
--   1. The Mac is connected to AC power
--   2. The Mac connects to specified Wi-Fi networks
-- =====================================================================

-- Target Wi-Fi SSIDs that should trigger maximum brightness
local targetSSIDs = {
	-- Add target Wi-Fi SSIDs here, e.g. "Home-WiFi", "Office-WiFi"
	"Heal_5G",
	"NZMNMKA",
}

-- Notify the user when Hammerspoon cannot read the current Wi-Fi SSID.
local function notifyLocationPermissionRequired(reason)
	print("auto max brightness: " .. reason)
	hs.notify
		.new({
			title = "Hammerspoon",
			subTitle = "Location permission required",
			informativeText = "Enable Hammerspoon in System Settings > Privacy & Security > Location Services to detect the current Wi-Fi network.",
		})
		:send()
end

-- Check if current Wi-Fi matches any target SSID
local function isTargetWifi()
	local currentNetwork = hs.wifi.currentNetwork()
	if not currentNetwork then
		return false
	end
	for _, ssid in ipairs(targetSSIDs) do
		if currentNetwork == ssid then
			return true
		end
	end
	return false
end

-- Callback function to adjust brightness when conditions are met
local function brightnessCallback()
	local isAC = hs.battery.powerSource() == "AC Power"
	if (isAC or isTargetWifi()) and hs.brightness.get() ~= 100 then
		hs.brightness.set(100)
	end
end

-- Request Location Services access because macOS requires it for reading SSIDs.
-- The request object is global so it stays alive until authorization completes.
local function ensureLocationPermission()
	if not hs.location.servicesEnabled() then
		notifyLocationPermissionRequired("Location Services are disabled")
		return
	end

	local status = hs.location.authorizationStatus()
	if status == "authorized" then
		return
	end

	if status ~= "undefined" then
		notifyLocationPermissionRequired("Location permission is " .. status)
		return
	end

	brightnessLocationPermissionRequest = hs.location.new()
	brightnessLocationPermissionRequest:callback(function(_, message, newStatus)
		if message ~= "didChangeAuthorizationStatus" or newStatus == "undefined" then
			return
		end

		brightnessLocationPermissionRequest:stopTracking()
		brightnessLocationPermissionRequest = nil

		if newStatus == "authorized" then
			brightnessCallback()
		else
			notifyLocationPermissionRequired("Location permission is " .. newStatus)
		end
	end)
	brightnessLocationPermissionRequest:startTracking()
end

-- Watchers (stored in module scope/globals to prevent garbage collection)
batteryWatcher = hs.battery.watcher.new(brightnessCallback)
wifiWatcher = hs.wifi.watcher.new(brightnessCallback)

batteryWatcher:start()
wifiWatcher:start()

print("auto max brightness register")

-- Check or request Location Services access before the initial Wi-Fi check.
ensureLocationPermission()

-- Run initial check on load
brightnessCallback()
