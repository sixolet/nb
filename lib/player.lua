local player = {
    length = 1.0
}

local refcounts = {}

function player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function player:note_on(note, vel)
end

function player:note_off(note)
end

function player:pitch_bend(note, amount)
end

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

function player:delayed_active()
end

function player:inactive()
    self.active = false
    if self.active_routine ~= nil then
        clock.cancel(self.active_routine)
    end
end

function player:count_up()
    if self.name ~= nil then
        if refcounts[self.name] == nil then
            refcounts[self.name] = 1
            self:active()
        else
            refcounts[self.name] = refcounts[self.name] + 1
        end
    end
end

function player:count_down()
    if self.name ~= nil then
        if refcounts[self.name] ~= nil then
            refcounts[self.name] = refcounts[self.name] - 1
            if refcounts[self.name] == 0 then
                refcounts[self.name] = nil
                self:inactive()
            end
        end
    end
end

function player:play_note(note, vel, length)
    self:note_on(note, vel)
    clock.run(function()
        clock.sleep(length*clock.get_beat_sec())
        self:note_off(note)
    end)
end

return player