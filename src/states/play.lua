local Snake = require("src.systems.snake")
local Food = require("src.systems.food")
local Levels = require("src.systems.levels")
local VirtualControls = require("src.systems.virtual_controls")

return function(game)
    local state = {
        level = nil,
        snake = nil,
        foods = nil,
        controls = VirtualControls.new(),
        tick_timer = 0,
        tick_length = 0.17,
        grid = {
            x = 96,
            y = 24,
            cell = 8,
        },
    }

    local function apply_penalty()
        game.session.lives = game.session.lives - 1
        game.session.level_stats.bad_hits = game.session.level_stats.bad_hits + 1
        game.session.score = math.max(0, game.session.score - 25)
    end

    function state:enter()
        self.level = Levels.get_level(game.dataset, game.session.level_index)
        self.snake = Snake.new(5, 5)
        self.foods = Food.spawn_set(self.level, self.snake)
        self.tick_timer = 0
        game.session.level_stats = {
            good_collected = 0,
            bad_hits = 0,
            time = 0,
        }
        game.audio:play_music(self.level.music)
    end

    function state:update(dt)
        game.session.level_stats.time = game.session.level_stats.time + dt
        self.tick_timer = self.tick_timer + dt

        local direction = game.input:get_direction_pressed()
        if direction then
            self.snake:set_direction(direction)
        end

        for _, tap in ipairs(game.input:get_taps()) do
            local touch_direction = self.controls:get_direction_at(tap.x, tap.y)
            if touch_direction then
                self.snake:set_direction(touch_direction)
            end
        end

        if game.input:back_pressed() then
            game.state_machine:change("menu")
            return
        end

        while self.tick_timer >= self.tick_length do
            self.tick_timer = self.tick_timer - self.tick_length
            local head = self.snake:move()

            if head.x < 0 or head.y < 0 or head.x >= self.level.grid_width or head.y >= self.level.grid_height then
                apply_penalty()
                self:reset_snake()
            elseif self.snake:has_self_collision() then
                apply_penalty()
                self:reset_snake()
            else
                local food = Food.consume_at(self.foods, head.x, head.y)
                if food then
                    if food.kind == "good" then
                        self.snake:grow(1)
                        game.session.score = game.session.score + 100
                        game.session.level_stats.good_collected = game.session.level_stats.good_collected + 1
                        game.audio:play_sfx(game.dataset.sfx.good_collect)
                    else
                        self.snake:shrink(1)
                        apply_penalty()
                        game.audio:play_sfx(game.dataset.sfx.bad_hit)
                    end
                end
            end

            if game.session.lives <= 0 then
                game.audio:stop_music()
                game.state_machine:change("game_over")
                return
            end

            if game.session.level_stats.good_collected >= self.level.goal_good then
                game.audio:stop_music()
                game.state_machine:change("level_stats")
                return
            end
        end
    end

    function state:reset_snake()
        self.snake = Snake.new(5, 5)
    end

    function state:draw_grid()
        love.graphics.setColor(0.12, 0.18, 0.14, 1)
        love.graphics.rectangle("fill", self.grid.x - 2, self.grid.y - 2, self.level.grid_width * self.grid.cell + 4, self.level.grid_height * self.grid.cell + 4)

        for y = 0, self.level.grid_height - 1 do
            for x = 0, self.level.grid_width - 1 do
                local tone = ((x + y) % 2 == 0) and 0.2 or 0.23
                love.graphics.setColor(0.06, tone, 0.08, 1)
                love.graphics.rectangle("fill", self.grid.x + x * self.grid.cell, self.grid.y + y * self.grid.cell, self.grid.cell, self.grid.cell)
            end
        end
    end

    function state:draw_foods()
        for _, food in ipairs(self.foods) do
            local image = food.kind == "good" and game.assets:get_image("good_food") or game.assets:get_image("bad_food")
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(image, self.grid.x + food.x * self.grid.cell, self.grid.y + food.y * self.grid.cell)
        end
    end

    function state:draw_snake()
        for index, segment in ipairs(self.snake.body) do
            if index == 1 then
                love.graphics.setColor(0.98, 0.78, 0.3, 1)
            else
                love.graphics.setColor(0.57, 0.82, 0.42, 1)
            end
            love.graphics.rectangle("fill", self.grid.x + segment.x * self.grid.cell, self.grid.y + segment.y * self.grid.cell, self.grid.cell, self.grid.cell)
        end
    end

    function state:draw_hud()
        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(game.localization:get(self.level.name_key), 8, 8)
        love.graphics.print(game.localization:get("hud_score", { score = game.session.score }), 8, 18)
        love.graphics.print(game.localization:get("hud_lives", { lives = game.session.lives }), 8, 28)
        love.graphics.print(game.localization:get("hud_goal", {
            current = game.session.level_stats.good_collected,
            total = self.level.goal_good,
        }), 8, 38)
    end

    function state:draw()
        love.graphics.setColor(0.05, 0.06, 0.08, 1)
        love.graphics.rectangle("fill", 0, 0, 256, 144)
        self:draw_grid()
        self:draw_foods()
        self:draw_snake()
        self:draw_hud()
        self.controls:draw(game.assets)
    end

    return state
end
