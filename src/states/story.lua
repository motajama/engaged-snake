local Typewriter = require("src.systems.typewriter")
local Levels = require("src.systems.levels")

return function(game)
    local state = {
        typewriter = nil,
        frame_timer = 0,
        frame = 1,
        level = nil,
    }

    function state:enter()
        self.level = Levels.get_level(game.dataset, game.session.level_index)
        local text = game.localization:get(self.level.story_key)
        self.typewriter = Typewriter.new(text, 45)
        self.frame_timer = 0
        self.frame = 1
    end

    function state:update(dt)
        self.frame_timer = self.frame_timer + dt
        if self.frame_timer >= 0.18 then
            self.frame_timer = self.frame_timer - 0.18
            self.frame = self.frame % 4 + 1
        end

        self.typewriter:update(dt)
        if game.input:any_pressed() then
            if self.typewriter:is_done() then
                game.state_machine:change("play")
            else
                self.typewriter:finish()
            end
        end
    end

    function state:draw()
        love.graphics.setColor(0.07, 0.08, 0.12, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)

        love.graphics.setColor(0.15, 0.18, 0.25, 1)
        love.graphics.rectangle("fill", 8, 12, 80, 80)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(game.assets:get_image("head"), game.assets:get_head_quad(self.frame), 16, 20)

        love.graphics.setColor(0.12, 0.14, 0.2, 1)
        love.graphics.rectangle("fill", 98, 12, 150, 100)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(game.assets:get_font("medium"))
        love.graphics.printf(game.localization:get(self.level.name_key), 106, 18, 134, "left")
        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(self.typewriter:get_text(), 106, 40, 134, "left")

        local footer_key = self.typewriter:is_done() and "story_continue" or "story_skip"
        love.graphics.printf(game.localization:get(footer_key), 0, 126, 256, "center")
    end

    return state
end
