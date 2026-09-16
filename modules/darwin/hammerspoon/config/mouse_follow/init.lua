-- ## Mouse Follow Across Screens
--
-- When a window receives focus on a different display from the mouse pointer,
-- the module moves the pointer to the center of that window.
-- Switching focus within the same display preserves the pointer position.
--
-- The module subscribes to Hammerspoon's
-- [`windowFocused` event](https://www.hammerspoon.org/docs/hs.window.filter.html#windowFocused),
-- so it works with Cmd+Tab, application shortcuts, and switching between an app's
-- windows when those actions generate a focus event. It also follows newly focused
-- windows after a slow app launch, without a fixed startup timeout.
--
-- - Set `FOLLOW_ACROSS_SCREENS_ONLY` to `false` to center the pointer on every
--   observed window focus change, including on the same display.
-- - The module uses its own default window filter, which excludes some transient
--   windows and applications. It does not change the input method module's filter.
-- - Focusing an empty desktop or moving an already focused window to another display
--   may not generate a window focus event, so these actions do not guarantee a move.
--
-- - The existing Option+backtick and Option+Shift+backtick display shortcuts in
--   `switch/init.lua` explicitly move the pointer to the target display's center,
--   including when it has no windows.

local FOLLOW_ACROSS_SCREENS_ONLY = true

local function centerMouseOn(win)
	if not win then
		return
	end

	local target = win:screen()
	if not target then
		return
	end

	-- Preserve the pointer position when focus changes within the same screen.
	if FOLLOW_ACROSS_SCREENS_ONLY then
		local current = hs.mouse.getCurrentScreen()
		if current and current:id() == target:id() then
			return
		end
	end

	hs.mouse.absolutePosition(win:frame().center)
end

-- Follow actual window focus, including windows opened after a slow app launch.
-- A separate default filter excludes transient windows without changing other modules.
local mouseFollowFilter = hs.window.filter.new()
mouseFollowFilter:subscribe(hs.window.filter.windowFocused, centerMouseOn)

-- Keep the subscription accessible through Lua's require cache.
return mouseFollowFilter
