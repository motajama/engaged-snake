return function(game)
    local state = {
        saved = false,
    }

    function state:enter()
        if not self.saved then
            game.save:add_highscore(game.highscores, {
                name = "PLY",
                score = game.session.score,
            })
            self.saved = true
        end
    end

    function state:update()
        if game.input:any_pressed() then
            game.state_machine:change("menu")
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(0.06, 0.12, 0.08, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setFont(game.assets:get_font("title"))
        love.graphics.setColor(0.97, 0.96, 0.7, 1)
        love.graphics.printf(game.localization:get("victory_title"), 0, 70, width, "center")
        love.graphics.setFont(game.assets:get_font("medium"))
        love.graphics.printf(game.localization:get("victory_body", { score = game.session.score }), 42, 122, width - 84, "center")
        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("continue_hint"), 0, height - 28, width, "center")
    end

    return state
end
