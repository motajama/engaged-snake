return function(game)
    local state = {
        selected = 1,
        items = {
            { kind = "toggle", key = "settings_music", setting = "music_enabled" },
            { kind = "toggle", key = "settings_sfx", setting = "sfx_enabled" },
            { kind = "cycle", key = "settings_difficulty", setting = "difficulty" },
            { kind = "cycle", key = "settings_video", setting = "video_mode" },
            { kind = "cycle", key = "settings_language", setting = "language" },
            { kind = "cycle", key = "settings_touch_controls", setting = "touch_controls" },
            { kind = "cycle", key = "settings_controls", setting = "control_layout" },
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
            local width = game.renderer.logical_width
            for index, item in ipairs(self.items) do
                local y = 64 + (index - 1) * 26
                if tap.x >= 24 and tap.x <= width - 24 and tap.y >= y - 2 and tap.y <= y + 18 then
                    self.selected = index
                    activate(item, 1)
                    return
                end
            end
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(0.08, 0.1, 0.15, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("settings_title"), 0, 20, width, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        for index, item in ipairs(self.items) do
            local y = 64 + (index - 1) * 26
            if index == self.selected then
                love.graphics.setColor(0.97, 0.78, 0.28, 0.95)
                love.graphics.rectangle("fill", 24, y - 2, width - 48, 20)
                love.graphics.setColor(0.06, 0.08, 0.12, 1)
            else
                love.graphics.setColor(0.18, 0.22, 0.3, 0.95)
                love.graphics.rectangle("fill", 24, y - 2, width - 48, 20)
                love.graphics.setColor(0.93, 0.96, 1, 1)
            end

            love.graphics.print(game.localization:get(item.key), 36, y + 2)
            love.graphics.setFont(game.assets:get_font("small"))
            love.graphics.printf(value_label(item), width - 160, y + 4, 124, "right")
            love.graphics.setFont(game.assets:get_font("medium"))
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("settings_hint"), 24, height - 24, width - 48, "center")
    end

    return state
end
