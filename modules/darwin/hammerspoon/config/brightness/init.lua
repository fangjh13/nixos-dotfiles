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
}

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
function brightnessCallback()
	local isAC = hs.battery.powerSource() == "AC Power"
	if (isAC or isTargetWifi()) and hs.brightness.get() ~= 100 then
		hs.brightness.set(100)
	end
end

-- Watchers (stored in module scope/globals to prevent garbage collection)
batteryWatcher = hs.battery.watcher.new(brightnessCallback)
wifiWatcher = hs.wifi.watcher.new(brightnessCallback)

batteryWatcher:start()
wifiWatcher:start()

print("auto max brightness register")

-- Run initial check on load
brightnessCallback()
