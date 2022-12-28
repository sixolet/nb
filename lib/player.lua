local player = {
    length = 1.0
}

if nb_player_refcounts == nil then
    nb_player_refcounts = {}
end

-- Wrap an object to be a full "player", with default implementations of all
-- the player methods
function player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Implement this to add params from your player to the script
function player:add_params()
end

-- Implement to do midi-style note-on. If you only implement play_note,
-- you should implement a trivial note_on to call it.
function player:note_on(note, vel)
end

-- Implement to do midi-style note-off. This is optional if you implement
-- play_note instead.
function player:note_off(note)
end

-- Optional. Send pitch bend to the voice. If the voice doesn't support
-- per-note pitch bend, may bend all notes. Amount is given in semitones.
function player:pitch_bend(note, amount)
end

-- Optional. Modulate the voice, in whatever way seems best. Range 0-1.
function player:modulate(attr, val)
end

-- Optional. Callback for when a voice is used by at least one selector.
-- Suggest using it to show parameters to control the voice.
function player:active()
    self.active = true
    self.active_routine = clock.run(function()
        clock.sleep(1)
        if self.active then
            self:delayed_active()
        end
        self.active_routine = nil
    end)
end

-- Optional. Callback for when a voice is slected for more than one second.
-- This is where you want to change modes on external devices or whatever.
function player:delayed_active()
end

-- Optional. Callback for when a voice is no longer used. Useful for hiding
-- parameters or whatnot.
function player:inactive()
    self.active = false
    if self.active_routine ~= nil then
        clock.cancel(self.active_routine)
    end
end

-- Stop all voices. Use on pset load.
function player:stop_all()
end

-- Play a note for a given length
function player:play_note(note, vel, length)
    self:note_on(note, vel)
    clock.run(function()
        clock.sleep(length*clock.get_beat_sec())
        self:note_off(note)
    end)
end

-- Private.
function player:count_up()
    if self.name ~= nil then
        if nb_player_refcounts[self.name] == nil then
            nb_player_refcounts[self.name] = 1
            self:active()
        else
            nb_player_refcounts[self.name] = nb_player_refcounts[self.name] + 1
        end
    end
end

-- Private
function player:count_down()
    if self.name ~= nil then
        if nb_player_refcounts[self.name] ~= nil then
            nb_player_refcounts[self.name] = nb_player_refcounts[self.name] - 1
            if nb_player_refcounts[self.name] == 0 then
                nb_player_refcounts[self.name] = nil
                self:inactive()
            end
        end
    end
end

return player