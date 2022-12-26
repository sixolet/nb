local mydir = debug.getinfo(1).source:match("@?".._path.code.."(.*/)")
local player_lib = include(mydir.."player")
local nb = {}

if note_players == nil then
    note_players = {}
end

-- note_players is a global that you can add note-players to from anywhere before
-- you call nb:add_param.
nb.players = note_players -- alias the global here. Helps with standalone use.

nb.none = player_lib:new()

-- Call from your init method.
function nb:init()
    refcounts = {}
    self:stop_all()
end

-- Add a voice select parameter. Returns the parameter. You can then call
-- `get_player()` on the parameter object, which will return a player you can
-- use to play notes and stuff.
function nb:add_param(param_id, param_name)
    local names = {}
    for name, _ in pairs(note_players) do
        table.insert(names, name)
    end
    table.sort(names)
    table.insert(names, 1, "none")
    local names_inverted = tab.invert(names)
    params:add_option(param_id, param_name, names, 1)
    local string_param_id = param_id.. "_hidden_string"
    params:add_text(string_param_id, "_hidden string", "")
    params:hide(string_param_id)
    local p = params:lookup_param(param_id)
    local initialized = false
    function p:get_player()
        local name = params:get(string_param_id)
        if name == "none" then
            if p.player ~= nil then
                p.player:count_down()
            end
            p.player = nil
            return nb.none
        elseif p.player ~= nil and p.player.name == name then
            return p.player
        else
            if p.player ~= nil then
                p.player:count_down()
            end
            local ret = player_lib:new(nb.players[name])
            ret.name = name
            p.player = ret
            ret:count_up()
            return ret
        end
    end
    clock.run(function()
        clock.sleep(1)
        p:get_player()
        initialized = true
    end, p)
    params:set_action(string_param_id, function(name_param)
        local i = names_inverted[params:get(string_param_id)]
        if i ~= nil then
            -- silently set the interface param.
            params:set(param_id, i, true)
        end
        p:get_player()
    end)
    params:set_action(param_id, function()
        if not initialized then return end
        local i = p:get()
        params:set(string_param_id, names[i])
    end)
end

-- Return all the players in an object by name. 
function nb:get_players()
    local ret = {}
    for k, v in pairs(self.players) do
        ret[k] = player_lib:new(v)
    end
    return ret
end

-- Stop all voices. Call when you load a pset to avoid stuck notes.
function nb:stop_all()
    for _, player in pairs(self:get_players()) do
        player:stop_all()
    end
end

return nb