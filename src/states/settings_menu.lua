return function(game)
    local state = {
        selected = 1,
        items = {
            { kind = "toggle", key = "settings_music", setting = "music_enabled" },
            { kind = "toggle", key = "settings_sfx", setting = "sfx_enabled" },
            { kind = "cycle", key = "settings_difficulty", setting = "difficulty" },
            { kind = "cycle", key = "settings_video", setting = "video_mode" },
            { kind = "cycle", key = "settings_language", setting = "language" },
        },
    }

    local function value_label(item)
        local value = game.settings.values[item.setting]
        if type(value) == "boolean" then
            return game.localization:get(value and "value_on" or "value_off")
        end
        return game.localization:get("value_" .. tostring(value))
    end

    local function activate(item, direction)
        if item.kind == "toggle" then
            game.settings:toggle(item.setting)
        else
            game.settings:cycle(item.setting, direction or 1)
        end

        if item.setting == "language" then
            game.localization:set_language(game.settings.values.language)
        end
    end

    function state:update()
        local direction = game.input:get_direction_pressed()
        if direction == "up" then
            self.selected = math.max(1, self.selected - 1)
        elseif direction == "down" then
            self.selected = math.min(#self.items, self.selected + 1)
        elseif direction == "left" then
            activate(self.items[self.selected], -1)
        elseif direction == "right" then
            activate(self.items[self.selected], 1)
        end

        if game.input:confirm_pressed() then
            activate(self.items[self.selected], 1)
        end

        if game.input:back_pressed() then
            game.state_machine:change("menu")
        end

        for _, tap in ipairs(game.input:get_taps()) do
            for index, item in ipairs(self.items) do
                local y = 30 + (index - 1) * 20
                if tap.x >= 24 and tap.x <= 232 and tap.y >= y and tap.y <= y + 16 then
                    self.selected = index
                    activate(item, 1)
                    return
                end
            end
        end
    end

    function state:draw()
        love.graphics.setColor(0.08, 0.1, 0.15, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("settings_title"), 0, 8, 256, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        for index, item in ipairs(self.items) do
            local y = 30 + (index - 1) * 20
            if index == self.selected then
                love.graphics.setColor(0.97, 0.78, 0.28, 0.95)
                love.graphics.rectangle("fill", 16, y - 2, 224, 18)
                love.graphics.setColor(0.06, 0.08, 0.12, 1)
            else
                love.graphics.setColor(0.18, 0.22, 0.3, 0.95)
                love.graphics.rectangle("fill", 16, y - 2, 224, 18)
                love.graphics.setColor(0.93, 0.96, 1, 1)
            end

            love.graphics.print(game.localization:get(item.key), 24, y + 2)
            love.graphics.printf(value_label(item), 120, y + 2, 108, "right")
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("settings_hint"), 12, 126, 232, "center")
    end

    return state
end
