return function(game)
    local state = {
        entries = {},
        source = "local",
        message_key = nil,
    }

    local function load_scores(state_ref)
        local ok, scores = game.online_scores:fetch_scores()
        if ok then
            state_ref.entries = scores
            state_ref.source = "online"
            state_ref.message_key = nil
            return
        end

        state_ref.entries = game.highscores.entries or {}
        state_ref.source = "local"
        state_ref.message_key = "highscore_local_fallback"
    end

    function state:enter()
        load_scores(self)
    end

    function state:update()
        if game.input:confirm_pressed() or game.input:back_pressed() or game.input:any_pressed() then
            game.state_machine:change("menu")
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        local header_y = self.message_key and 70 or 50
        love.graphics.setColor(0.08, 0.08, 0.12, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("highscore_title"), 0, 18, width, "center")

        if self.message_key then
            love.graphics.setFont(game.assets:get_font("small"))
            love.graphics.setColor(0.95, 0.78, 0.36, 1)
            love.graphics.printf(game.localization:get(self.message_key), 28, 42, width - 56, "center")
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(1, 1, 1, 1)
        if #self.entries == 0 then
            local empty_key = self.source == "online" and "highscore_online_empty" or "highscore_empty"
            love.graphics.printf(game.localization:get(empty_key), 0, 116, width, "center")
        else
            love.graphics.setColor(0.66, 0.75, 0.84, 1)
            love.graphics.printf("#", 30, header_y, 24, "right")
            love.graphics.printf(game.localization:get("highscore_player_header"), 64, header_y, 100, "left")
            love.graphics.printf(game.localization:get("highscore_score_header"), 166, header_y, 58, "right")
            love.graphics.printf(game.localization:get("highscore_level_header"), 238, header_y, 38, "right")
            love.graphics.printf(game.localization:get("highscore_win_header"), 286, header_y, 18, "center")

            for index, entry in ipairs(self.entries) do
                local y = header_y + 8 + index * 14
                local marker = entry.victory and "*" or " "
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(string.format("%02d", index), 30, y, 24, "right")
                love.graphics.printf(tostring(entry.name or "PLY"):sub(1, 12), 64, y, 100, "left")
                love.graphics.printf(string.format("%05d", entry.score or 0), 166, y, 58, "right")
                love.graphics.printf(tostring(entry.level_ended or "-"), 238, y, 38, "right")
                love.graphics.printf(marker, 286, y, 18, "center")
            end
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("back_hint"), 0, height - 24, width, "center")
    end

    return state
end
