local Audio = {}
Audio.__index = Audio

local function build_tone(frequency, duration, volume, waveform)
    local sample_rate = 22050
    local samples = math.max(1, math.floor(sample_rate * duration))
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local sample
        if waveform == "square" then
            sample = math.sin(2 * math.pi * frequency * t) >= 0 and 1 or -1
        else
            sample = math.sin(2 * math.pi * frequency * t)
        end
        local envelope = 1 - (i / samples)
        sound_data:setSample(i, sample * volume * envelope)
    end

    local source = love.audio.newSource(sound_data, "static")
    source:setVolume(0.35)
    return source
end

function Audio.new(settings)
    return setmetatable({
        settings = settings,
        current_music = nil,
        generated_sfx = {
            pickup_good = build_tone(880, 0.08, 0.5, "square"),
            pickup_bad = build_tone(220, 0.12, 0.6, "square"),
            stats_tick = build_tone(680, 0.035, 0.45, "square"),
            stats_done = build_tone(1040, 0.10, 0.45, "sine"),
            menu_move = build_tone(500, 0.05, 0.35, "square"),
            menu_confirm = build_tone(760, 0.08, 0.4, "square"),
        },
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

    local source = self.generated_sfx[_sfx_id]
    if source then
        local clone = source:clone()
        clone:play()
    end
end

return Audio
