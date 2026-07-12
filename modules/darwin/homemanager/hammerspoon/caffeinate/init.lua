-- =====================================================================
-- Screen Keep-Awake Countdown Tool (Amphetamine-like)
-- =====================================================================
--
-- Adds a coffee-cup icon (☕) to the macOS menu bar. Clicking it lets
-- you keep the display awake for a fixed duration (10/20/30 min, 1 h)
-- or indefinitely. While active, the menu bar shows a live countdown
-- (e.g. "☕ 19:42") or "☕ ∞" in indefinite mode. When the countdown
-- ends (or you stop it manually), the system's normal display-sleep
-- settings are restored and a notification is sent.
--
-- HOW IT WORKS:
--   * Keep-awake mechanism: hs.caffeinate.set("displayIdle", true, true)
--     creates a power assertion that prevents the display from dimming
--     or sleeping. The third argument (true) makes it apply on both AC
--     power and battery. Setting it back to false releases the
--     assertion and lets macOS take over again.
--   * Countdown accuracy: instead of decrementing a counter every tick
--     (which drifts when timer ticks are missed), we store an absolute
--     end timestamp and recompute the remaining time on every refresh.
--   * Reload safety: power assertions live on the Hammerspoon process
--     and survive a config reload, while Lua state does not. So on
--     load we always force-release the assertion and delete any old
--     menu bar icon, and hs.shutdownCallback restores defaults when
--     Hammerspoon quits.
--   * State is kept in a single global table (Awake) so it is not
--     garbage-collected and does not pollute the global namespace.
-- =====================================================================

-- Global state table (global so it survives garbage collection)
Awake = Awake or { menu = nil, timer = nil, endTime = nil, active = false }

-- --- Reload safety -----------------------------------------------------
-- Remove the old menu bar icon left over from a previous config load
if Awake.menu then
	Awake.menu:delete()
	Awake.menu = nil
end
if Awake.timer then
	Awake.timer:stop()
	Awake.timer = nil
end
-- Force-release any leaked power assertion from before the reload
hs.caffeinate.set("displayIdle", false, true)
Awake.active = false
Awake.endTime = nil

-- --- Configuration -----------------------------------------------------
-- Preset durations shown in the dropdown menu. Add or edit entries here.
local DURATIONS = {
	{ label = "Keep awake for 10 minutes", minutes = 10 },
	{ label = "Keep awake for 20 minutes", minutes = 20 },
	{ label = "Keep awake for 30 minutes", minutes = 30 },
	{ label = "Keep awake for 1 hour", minutes = 60 },
}

local IDLE_ICON = "☕"

-- --- Core functions ----------------------------------------------------

-- Stop keeping the display awake and restore system default behavior
function StopAwake()
	if Awake.timer then
		Awake.timer:stop()
		Awake.timer = nil
	end

	-- Release the displayIdle assertion so macOS resumes control and
	-- the display dims/sleeps according to System Settings again
	hs.caffeinate.set("displayIdle", false, true)

	Awake.active = false
	Awake.endTime = nil
	Awake.menu:setTitle(IDLE_ICON)
end

-- Recompute remaining time from the absolute end timestamp and update
-- the menu bar title. Ends the session when time runs out.
local function refresh()
	local remaining = math.floor(Awake.endTime - hs.timer.secondsSinceEpoch())

	if remaining <= 0 then
		StopAwake()
		hs.notify
			.new({
				title = "Hammerspoon",
				informativeText = "Keep-awake session ended. System sleep settings restored.",
			})
			:send()
	else
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		Awake.menu:setTitle(string.format("%s %02d:%02d", IDLE_ICON, mins, secs))
	end
end

-- Start keeping the display awake.
--   minutes = number  -> timed session with a live countdown
--   minutes = nil     -> indefinite session (no timer, shows "☕ ∞")
function StartAwake(minutes)
	if Awake.timer then
		Awake.timer:stop()
		Awake.timer = nil
	end

	Awake.active = true

	-- Create the power assertion: prevent display dimming/sleep.
	-- Third argument (true) = apply on both AC power and battery.
	hs.caffeinate.set("displayIdle", true, true)

	if minutes then
		Awake.endTime = hs.timer.secondsSinceEpoch() + minutes * 60
		refresh() -- update the UI immediately
		Awake.timer = hs.timer.doEvery(1, refresh)
	else
		Awake.endTime = nil
		Awake.menu:setTitle(IDLE_ICON .. " ∞")
	end
end

-- --- Menu --------------------------------------------------------------

-- Build the dropdown menu dynamically based on current state
local function generateMenu()
	if Awake.active then
		return {
			{ title = "Stop keeping awake (restore defaults)", fn = StopAwake },
		}
	end

	local items = {}
	for _, d in ipairs(DURATIONS) do
		table.insert(items, {
			title = d.label,
			fn = function()
				StartAwake(d.minutes)
			end,
		})
	end
	table.insert(items, { title = "-" }) -- separator
	table.insert(items, {
		title = "Keep awake indefinitely",
		fn = function()
			StartAwake(nil)
		end,
	})
	return items
end

-- --- Initialization ----------------------------------------------------

Awake.menu = hs.menubar.new()
if Awake.menu then
	Awake.menu:setTitle(IDLE_ICON)
	Awake.menu:setMenu(generateMenu)
end

-- Ensure system defaults are restored when Hammerspoon itself quits
hs.shutdownCallback = StopAwake
