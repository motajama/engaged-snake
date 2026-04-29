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
        love.graphics.setColor(0.12, 0.02, 0.04, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)
        love.graphics.setFont(game.assets:get_font("title"))
        love.graphics.setColor(1, 0.85, 0.85, 1)
        love.graphics.printf(game.localization:get("game_over_title"), 0, 42, 256, "center")
        love.graphics.setFont(game.assets:get_font("medium"))
        love.graphics.printf(game.localization:get("game_over_body"), 24, 76, 208, "center")
        if self.timer > 1 then
            love.graphics.setFont(game.assets:get_font("small"))
            love.graphics.printf(game.localization:get("game_over_hint"), 16, 122, 224, "center")
        end
    end

    return state
end
