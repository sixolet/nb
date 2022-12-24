local player_lib = require "nb/lib/player"

local nb = {}

if note_players == nil then
    note_players = {}
end

nb.players = note_players -- alias the global here. Helps with standalone use.

nb.none = player_lib:new()

function nb:add_param(param_id, param_name)
    local names = {}
    for name, _ in pairs(note_players) do
        table.insert(names, name)
    end
    table.sort(names)
    table.insert(names, 1, "none")
    params:add_option(param_id, param_name, names, 1)
    local p = params:lookup_param(param_id)
    function p:get_player()
        local i = p:get()
        local name = names[i]
        if name == "none" then
            if p.player ~= nil then
                p.player:inactive()
            end
            p.player = nil
            return nb.none
        elseif p.player ~= nil and p.player.name == name then
            return p.player
        else
            if p.player ~= nil then
                p.player:inactive()
            end
            local ret = player_lib:new(nb.players[name])
            ret.name = name
            p.player = ret
            ret:active()
            return ret
        end
    end
    params:set_action(param_id, function()
        p:get_player()
    end)
end

return nb