return function(game)
    local state = {
        timer = 0,
    }

    function state:enter()
        self.timer = 0
    end

    function state:update(dt)
        self.timer = self.timer + dt
        if self.timer > 1 and game.input:any_pressed() then
            if game.input:confirm_pressed() then
                game:start_new_run()
                game.state_machine:change("story")
            else
                game.state_machine:change("menu")
            end
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(game.assets:get_image("game_over"), 0, 0)
        love.graphics.setColor(0.08, 0.02, 0.04, 0.42)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setFont(game.assets:get_font("title"))
        love.graphics.setColor(1, 0.85, 0.85, 1)
        love.graphics.printf(game.localization:get((game.dataset.game_over and game.dataset.game_over.title_key) or "game_over_title"), 0, 78, width, "center")
        love.graphics.setFont(game.assets:get_font("medium"))
        love.graphics.printf(game.localization:get((game.dataset.game_over and game.dataset.game_over.body_key) or "game_over_body"), 42, 126, width - 84, "center")
        if self.timer > 1 then
            love.graphics.setFont(game.assets:get_font("small"))
            love.graphics.printf(game.localization:get((game.dataset.game_over and game.dataset.game_over.hint_key) or "game_over_hint"), 24, height - 28, width - 48, "center")
        end
    end

    return state
end
