return function(game)
    local state = {}

    function state:update()
        if game.input:confirm_pressed() or game.input:back_pressed() or game.input:any_pressed() then
            game.state_machine:change("menu")
        end
    end

    function state:draw()
        love.graphics.setColor(0.08, 0.08, 0.12, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("highscore_title"), 0, 10, 256, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        if #game.highscores.entries == 0 then
            love.graphics.printf(game.localization:get("highscore_empty"), 0, 66, 256, "center")
        else
            for index, entry in ipairs(game.highscores.entries) do
                local y = 28 + index * 10
                local line = string.format("%02d  %s  %05d", index, entry.name or "PLY", entry.score or 0)
                love.graphics.printf(line, 28, y, 200, "left")
            end
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("back_hint"), 0, 130, 256, "center")
    end

    return state
end
