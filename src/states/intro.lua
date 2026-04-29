return function(game)
    local state = {
        timer = 0,
        duration = 3,
    }

    function state:enter()
        self.timer = 0
        self.duration = (game.dataset.intro and game.dataset.intro.duration) or 3
    end

    function state:update(dt)
        self.timer = self.timer + dt
        if self.timer >= self.duration or game.input:any_pressed() then
            game.state_machine:change("menu")
        end
    end

    function state:draw()
        local progress = math.min(1, self.timer / self.duration)
        local pulse = 0.3 + 0.7 * progress
        love.graphics.setColor(0.09, 0.08 + pulse * 0.2, 0.16, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)

        love.graphics.setColor(1, 0.9, 0.45, 1)
        love.graphics.setFont(game.assets:get_font("title"))
        love.graphics.printf(game.localization:get("intro_title"), 0, 40, 256, "center")
        love.graphics.setFont(game.assets:get_font("medium"))
        love.graphics.setColor(0.85, 0.95, 1, 1)
        love.graphics.printf(game.localization:get("intro_body"), 28, 74, 200, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("intro_skip"), 0, 124, 256, "center")
    end

    return state
end
