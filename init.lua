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
    {{"ctrl"}, "N", "Anki"}
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
    if rawFlags == 131330 then
        lhs.eventtap.keyStroke({"cmd"}, "[")
        return true
    end
    if rawFlags == 262401 then
        lhs.eventtap.keyStroke({"cmd"}, "]")
        return true
    end
    return false
end

local eventtap = lhs.eventtap.new({lhs.eventtap.event.types.flagsChanged},
                                  handleEvent)
eventtap:start()
