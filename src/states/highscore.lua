return function(game)
    local state = {}

    function state:update()
        if game.input:confirm_pressed() or game.input:back_pressed() or game.input:any_pressed() then
            game.state_machine:change("menu")
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(0.08, 0.08, 0.12, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("highscore_title"), 0, 18, width, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        if #game.highscores.entries == 0 then
            love.graphics.printf(game.localization:get("highscore_empty"), 0, 116, width, "center")
        else
            for index, entry in ipairs(game.highscores.entries) do
                local y = 42 + index * 16
                local marker = entry.victory and "*" or " "
                local level = entry.level_ended and (" L" .. tostring(entry.level_ended)) or ""
                local line = string.format("%02d %s %-12s %05d%s", index, marker, entry.name or "PLY", entry.score or 0, level)
                love.graphics.printf(line, 46, y, width - 92, "left")
            end
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("back_hint"), 0, height - 24, width, "center")
    end

    return state
end
