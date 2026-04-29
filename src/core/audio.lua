local Audio = {}
Audio.__index = Audio

function Audio.new(settings)
    return setmetatable({
        settings = settings,
        current_music = nil,
    }, Audio)
end

function Audio:play_music(track_id)
    self.current_music = track_id
end

function Audio:stop_music()
    self.current_music = nil
end

function Audio:play_sfx(_sfx_id)
    if not self.settings.values.sfx_enabled then
        return
    end
end

return Audio
