local lhs = hs
lhs.logger.setGlobalLogLevel("debug")

lhs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({
	left = { { "ctrl", "cmd" }, "left" },
	right = { { "ctrl", "cmd" }, "right" },
	up = { { "ctrl", "cmd" }, "up" },
	down = { { "ctrl", "cmd" }, "down" },
	maximum = { { "ctrl", "cmd" }, "m" },
})

local keys = {
	{ { "ctrl" }, "P",     "WezTerm" },
	{ { "ctrl" }, "O",     "Google Chrome" },
	{ { "ctrl" }, "M",     "DBeaver" },
	{ { "ctrl" }, "Y",     "Spotify" },
	{ { "ctrl" }, "N",     "Anki" },
	{ { "ctrl" }, ";",     "Figma" },
	{ { "ctrl" }, "space", "Ghostty" },
	{ { "ctrl" }, ",",     "Cursor" },
}

for _, key in ipairs(keys) do
	lhs.hotkey.bind(key[1], key[2], function()
		local app = lhs.application.find(key[3])
		if app then
			if app:isFrontmost() then
				app:hide()
			else
				app:activate()
			end
		else
			lhs.application.launchOrFocus(key[3])
		end
	end)
end

local function handleEvent(event)
	local rawFlags = event:rawFlags()
	-- Modify the numbers in conditions to be allocated to your keyboard with HammerSpoon
	-- print(rawFlags)
	if rawFlags == 1974574 then
		lhs.eventtap.keyStroke({ "cmd" }, "[")
		return true
	end
	if rawFlags == 1966389 then
		lhs.eventtap.keyStroke({ "cmd" }, "]")
		return true
	end
	return false
end

-- https://chat.openai.com/share/1aa92488-436c-434c-935b-65e61e458e25
_G.eventtap = lhs.eventtap.new({ lhs.eventtap.event.types.flagsChanged }, handleEvent)
_G.eventtap:start()

----------------------------------------
-- Google Chrome Window Management
----------------------------------------
local chromeToRight = lhs.hotkey.new({ "ctrl" }, "l", function()
	lhs.eventtap.keyStroke({ "cmd", "option" }, "Right", 0)
end)

local chromeToLeft = lhs.hotkey.new({ "ctrl" }, "h", function()
	lhs.eventtap.keyStroke({ "cmd", "option" }, "Left", 0)
end)

-- Initialize a Google Chrome window filter
local GoogleChromeWF = lhs.window.filter.new("Google Chrome")

-- Subscribe to when your Google Chrome window is focused and unfocused
GoogleChromeWF:subscribe(lhs.window.filter.windowFocused, function()
	-- Enable hotkey in Google Chrome
	chromeToLeft:enable()
	chromeToRight:enable()
end):subscribe(lhs.window.filter.windowUnfocused, function()
	-- Disable hotkey when focusing out of Google Chrome
	chromeToLeft:disable()
	chromeToRight:disable()
end)

----------------------------------------
-- Directional Keybindings
----------------------------------------
local repeatKey = nil

local function keyHoldHandler(key)
	-- Initialize or reset the timer to periodically trigger the keyStroke
	if repeatKey then
		repeatKey:stop() -- Stop the existing timer if it exists
	end
	repeatKey = lhs.timer.new(0.0001, function()
		lhs.eventtap.keyStroke({}, key, true)
	end)
	repeatKey:start()
end

lhs.hotkey.bind({ "ctrl", "option" }, "l", function()
	keyHoldHandler("Right")
end, function()    -- This function is called on key release
	if repeatKey then
		repeatKey:stop() -- Stop the timer when the keys are released
	end
end)
lhs.hotkey.bind({ "ctrl", "option" }, "h", function()
	keyHoldHandler("Left")
end, function()    -- This function is called on key release
	if repeatKey then
		repeatKey:stop() -- Stop the timer when the keys are released
	end
end)
lhs.hotkey.bind({ "ctrl", "option" }, "j", function()
	keyHoldHandler("Down")
end, function()    -- This function is called on key release
	if repeatKey then
		repeatKey:stop() -- Stop the timer when the keys are released
	end
end)
lhs.hotkey.bind({ "ctrl", "option" }, "k", function()
	keyHoldHandler("Up")
end, function()    -- This function is called on key release
	if repeatKey then
		repeatKey:stop() -- Stop the timer when the keys are released
	end
end)

lhs.hotkey.bind({ "ctrl", "option" }, "'", function()
	lhs.application.launchOrFocus("QuickTime Player")
	lhs.timer.doAfter(1, function()
		local quicktime = lhs.appfinder.appFromName("QuickTime Player")
		if quicktime then˙
			-- Close the window in Finder
			lhs.eventtap.keyStroke({}, "Escape")
			-- Open a new window to record the current screen
			lhs.eventtap.keyStroke({ "ctrl", "cmd" }, "n")
		end
	end)
end)

----------------------------------------
-- External Display Window Management
----------------------------------------
lhs.hotkey.bind({ "ctrl", "option" }, "u", function()
	local logger = lhs.logger.new("windowManagement", "debug")
	local apps = {
		{ name = "Google Chrome",      resize = true },
		{ name = "Ghostty",            resize = true },
		{ name = "WezTerm",            resize = true },
		{ name = "DBeaver",            resize = true },
		{ name = "Spotify",            resize = true },
		{ name = "Figma",              resize = true },
		{ name = "Hammerspoon",        resize = false },
		{ name = "Anki",               resize = false },
		{ name = "DevToys",            resize = false },
		{ name = "DeepL",              resize = false },
		{ name = "Finder",             resize = false },
		{ name = "OrbStack",           resize = false },
		{ name = "Slack",              resize = false },
		{ name = "ovice",              resize = false },
		{ name = "Visual Studio Code", resize = true },
	}
	local screens = lhs.screen.allScreens()
	if #screens < 2 then
		lhs.alert.show("External display not found!")
		return
	end
	for _, appInfo in ipairs(apps) do
		local app = lhs.application.find(appInfo.name)
		if app then
			local win = app:mainWindow()
			if win then
				-- Specify display (1: main display, 2: external display)
				local mainScreen = screens[1]
				local externalScreen = screens[2]

				local winFrame = win:frame()
				local winScreen = lhs.screen.find(winFrame)
				local frame = externalScreen:frame()

				logger.d(string.format("appName: %s", appInfo.name))
				logger.d(
					string.format(
						"Window position: x=%d, y=%d, w=%d, h=%d",
						winFrame.x,
						winFrame.y,
						winFrame.w,
						winFrame.h
					)
				)
				logger.d(string.format("external position: x=%d, y=%d, w=%d, h=%d", frame.x, frame.y, frame.w, frame.h))

				if appInfo.resize then
					-- Set the window frame to the external display
					win:setFrame(frame)
					-- if application has already been in external display
				elseif winScreen == mainScreen then
					-- Set the window frame to the external display without resizing
					local newFrame = hs.geometry.rect(frame.x / 2, winFrame.y, winFrame.w, winFrame.h)
					win:setFrame(newFrame)
				end
			end
		else
			logger.ef("%s not found!", appInfo.name)
		end
	end
end)

-- Initialize state variables
local chromeWindows = {}
local currentWindowIndex = 0

-- Logger for debugging
local log = lhs.logger.new("windowManager", "debug")

-- Function to update the Chrome windows list
local function updateChromeWindows()
	local chrome = lhs.application.find("Google Chrome")
	if not chrome then
		log.w("Google Chrome is not running.")
		chromeWindows = {}
		currentWindowIndex = 0
		return
	end

	local allWindows = chrome:allWindows()
	if not allWindows then
		log.w("No Chrome windows found.")
		chromeWindows = {}
		currentWindowIndex = 0
		return
	end

	chromeWindows = {}
	for _, win in ipairs(allWindows) do
		table.insert(chromeWindows, win)
	end

	log.d("Updated Chrome windows list. Total windows: " .. #chromeWindows)
end

-- Function to handle window focus
local function chromeWindowFocused(win)
	for index, window in ipairs(chromeWindows) do
		if window:id() == win:id() then
			currentWindowIndex = index
			log.d("Focused on window #" .. currentWindowIndex)
			break
		end
	end
end

-- Function to handle window creation
local function chromeWindowCreated(win)
	log.d("Chrome window created: " .. (win:title() or "Untitled"))
	updateChromeWindows()
end

-- Function to handle window destruction
local function chromeWindowDestroyed(win)
	log.d("Chrome window destroyed: " .. (win:title() or "Untitled"))
	updateChromeWindows()
end

-- Set up the window filter for Google Chrome
local chromeWF = lhs.window.filter.new("Google Chrome"):setDefaultFilter({})

-- Subscribe to window events
chromeWF:subscribe(lhs.window.filter.windowFocused, chromeWindowFocused)
chromeWF:subscribe(lhs.window.filter.windowCreated, chromeWindowCreated)
chromeWF:subscribe(lhs.window.filter.windowDestroyed, chromeWindowDestroyed)

-- Initial population of Chrome windows
updateChromeWindows()

-- Set up a timer to refresh Chrome windows every 5 seconds (optional)
local refreshTimer = lhs.timer.new(5, function()
	updateChromeWindows()
end)
refreshTimer:start()

-- Define the hyper key combination
local hyper = { "ctrl", "option" }

-- Bind the hyper + k key to cycle Chrome windows
lhs.hotkey.bind(hyper, "m", function()
	if #chromeWindows == 0 then
		lhs.alert.show("No Chrome windows to cycle through!")
		return
	end

	-- Calculate the next window index
	local nextIndex = currentWindowIndex + 1
	if nextIndex > #chromeWindows then
		nextIndex = 1 -- Wrap around to the first window
	end

	-- Focus the next window
	local nextWindow = chromeWindows[nextIndex]
	if nextWindow then
		nextWindow:focus()
		currentWindowIndex = nextIndex
		log.i("Cycling to Chrome window #" .. currentWindowIndex)
	else
		log.e("Failed to focus Chrome window #" .. nextIndex)
	end
end)

----------------------------------------
-- Chrome Video Control
----------------------------------------
local videoControlHotkeys = {
	forward = lhs.hotkey.new({ "ctrl", "shift" }, "right", function()
		local chrome = lhs.application.find("Google Chrome")
		if chrome and chrome:isFrontmost() then
			-- JavaScript to seek forward 5 seconds
			local script = [[
				var videos = document.querySelectorAll('video');
				if (videos.length > 0) {
					for (var i = 0; i < videos.length; i++) {
						if (!videos[i].paused) {
							videos[i].currentTime += 5;
							break;
						}
					}
				}
			]]
			lhs.osascript.javascript(script)
			lhs.alert.show("⏩ +5s")
		end
	end),

	backward = lhs.hotkey.new({ "ctrl", "shift" }, "left", function()
		local chrome = lhs.application.find("Google Chrome")
		if chrome and chrome:isFrontmost() then
			-- JavaScript to seek backward 5 seconds
			local script = [[
				var videos = document.querySelectorAll('video');
				if (videos.length > 0) {
					for (var i = 0; i < videos.length; i++) {
						if (!videos[i].paused) {
							videos[i].currentTime -= 5;
							break;
						}
					}
				}
			]]
			lhs.osascript.javascript(script)
			lhs.alert.show("⏪ -5s")
		end
	end),
}

-- Initialize a Google Chrome window filter for video controls
local ChromeVideoWF = lhs.window.filter.new("Google Chrome")

-- Enable hotkeys only when Chrome is focused
ChromeVideoWF:subscribe(lhs.window.filter.windowFocused, function()
	videoControlHotkeys.forward:enable()
	videoControlHotkeys.backward:enable()
end):subscribe(lhs.window.filter.windowUnfocused, function()
	videoControlHotkeys.forward:disable()
	videoControlHotkeys.backward:disable()
end)
