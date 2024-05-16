local lhs = hs

lhs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({
    left = {{'ctrl', 'cmd'}, 'left'},
    right = {{'ctrl', 'cmd'}, 'right'},
    up = {{'ctrl', 'cmd'}, 'up'},
    down = {{'ctrl', 'cmd'}, 'down'},
    maximum = {{'ctrl', 'cmd'}, 'm'}
});

local keys = {
    {{"ctrl"}, "P", "WezTerm"}, {{"ctrl"}, "O", "Google Chrome"},
    {{"ctrl"}, "M", "DBeaver"}, {{"ctrl"}, "Y", "Spotify"},
    {{"ctrl"}, "N", "Anki"}, {{"ctrl"}, ";", "Figma"}
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
        lhs.eventtap.keyStroke({"cmd"}, "[")
        return true
    end
    if rawFlags == 1966389 then
        lhs.eventtap.keyStroke({"cmd"}, "]")
        return true
    end
    return false
end

-- https://chat.openai.com/share/1aa92488-436c-434c-935b-65e61e458e25
_G.eventtap = lhs.eventtap.new({lhs.eventtap.event.types.flagsChanged},
                               handleEvent)
_G.eventtap:start()

----------------------------------------
-- Google Chrome Window Management
----------------------------------------
local chromeToRight = lhs.hotkey.new({"ctrl"}, "l", function()
    lhs.eventtap.keyStroke({"cmd", "option"}, "Right", 0)
end)

local chromeToLeft = lhs.hotkey.new({"ctrl"}, "h", function()
    lhs.eventtap.keyStroke({"cmd", "option"}, "Left", 0)
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

lhs.hotkey.bind({"ctrl", "option"}, "l", function() keyHoldHandler("Right") end,
                function() -- This function is called on key release
    if repeatKey then
        repeatKey:stop() -- Stop the timer when the keys are released
    end
end)
lhs.hotkey.bind({"ctrl", "option"}, "h", function() keyHoldHandler("Left") end,
                function() -- This function is called on key release
    if repeatKey then
        repeatKey:stop() -- Stop the timer when the keys are released
    end
end)
lhs.hotkey.bind({"ctrl", "option"}, "j", function() keyHoldHandler("Down") end,
                function() -- This function is called on key release
    if repeatKey then
        repeatKey:stop() -- Stop the timer when the keys are released
    end
end)
lhs.hotkey.bind({"ctrl", "option"}, "k", function() keyHoldHandler("Up") end,
                function() -- This function is called on key release
    if repeatKey then
        repeatKey:stop() -- Stop the timer when the keys are released
    end
end)

lhs.hotkey.bind({"ctrl", "option"}, "'", function()
    lhs.application.launchOrFocus("QuickTime Player")
    lhs.timer.doAfter(1, function()
        local quicktime = lhs.appfinder.appFromName("QuickTime Player")
        if quicktime then
            -- Close the window in Finder
            lhs.eventtap.keyStroke({}, "Escape")
            -- Open a new window to record the current screen
            lhs.eventtap.keyStroke({"ctrl", "cmd"}, "n")
        end
    end)
end)
