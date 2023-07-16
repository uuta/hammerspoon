hs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({
    left = {{'ctrl', 'cmd'}, 'left'},
    right = {{'ctrl', 'cmd'}, 'right'},
    up = {{'ctrl', 'cmd'}, 'up'},
    down = {{'ctrl', 'cmd'}, 'down'},
    maximum = {{'ctrl', 'cmd'}, 'm'}
});

-- TODO: Consolidate processes into a single function
hs.hotkey.bind({"ctrl"}, "P",
               function() hs.application.launchOrFocus("WezTerm") end)

hs.hotkey.bind({"ctrl"}, "O",
               function() hs.application.launchOrFocus("Google Chrome") end)

hs.hotkey.bind({"ctrl"}, "U",
               function() hs.application.launchOrFocus("DBeaver") end)

hs.hotkey.bind({"ctrl"}, "Y",
               function() hs.application.launchOrFocus("Spotify") end)
