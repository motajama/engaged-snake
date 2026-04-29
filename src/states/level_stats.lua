local Levels = require("src.systems.levels")

return function(game)
    local state = {
        level = nil,
    }

    function state:enter()
        self.level = Levels.get_level(game.dataset, game.session.level_index)
    end

    function state:update()
        if game.input:any_pressed() then
            if game.session.level_index >= Levels.count(game.dataset) then
                game.state_machine:change("victory")
            else
                game.session.level_index = game.session.level_index + 1
                game.state_machine:change("story")
            end
        end
    end

    function state:draw()
        local stats = game.session.level_stats
        love.graphics.setColor(0.05, 0.05, 0.09, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)
        love.graphics.setColor(0.2, 0.7, 0.3, 1)
        love.graphics.rectangle("fill", 10, 10, 236, 124)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(0.02, 0.06, 0.02, 1)
        love.graphics.printf(game.localization:get("stats_title"), 0, 18, 256, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        local lines = {
            game.localization:get("stats_level", { level = game.localization:get(self.level.name_key) }),
            game.localization:get("stats_good", { value = stats.good_collected }),
            game.localization:get("stats_bad", { value = stats.bad_hits }),
            game.localization:get("stats_lives", { value = game.session.lives }),
            game.localization:get("stats_time", { value = string.format("%.1f", stats.time) }),
            game.localization:get("stats_score", { value = game.session.score }),
        }

        for index, line in ipairs(lines) do
            love.graphics.printf(line, 28, 40 + (index - 1) * 12, 200, "left")
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("continue_hint"), 0, 118, 256, "center")
    end

    return state
end
