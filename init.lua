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
    chromeToRight:enable()
end)

----------------------------------------
-- Directional Keybindings
----------------------------------------
lhs.hotkey.bind({"ctrl", "shift"}, "l",
                function() lhs.eventtap.keyStroke({}, "Right", true) end)
--
lhs.hotkey.bind({"ctrl", "shift"}, "h",
                function() lhs.eventtap.keyStroke({}, "Left", true) end)

lhs.hotkey.bind({"ctrl", "shift"}, "j",
                function() lhs.eventtap.keyStroke({}, "Down", true) end)

lhs.hotkey.bind({"ctrl", "shift"}, "k",
                function() lhs.eventtap.keyStroke({}, "Up", true) end)
