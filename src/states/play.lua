local Snake = require("src.systems.snake")
local Food = require("src.systems.food")
local Levels = require("src.systems.levels")
local VirtualControls = require("src.systems.virtual_controls")
local HUDQuotes = require("src.systems.hud_quotes")

return function(game)
    local state = {
        level = nil,
        difficulty = nil,
        snake = nil,
        foods = nil,
        controls = VirtualControls.new(),
        quotes = HUDQuotes.new(),
        tick_timer = 0,
        tick_length = 0.17,
        speed = 6,
        speed_increment = 0.25,
        goal_good = 0,
        hud_height = 32,
        grid = {
            x = 0,
            y = 0,
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
        self.difficulty = game:get_difficulty_profile(game.settings.values.difficulty)
        self.snake = Snake.new(5, 5)
        self.food_counts = {
            good_count = math.max(1, math.floor(self.level.good_count * (self.difficulty.good_food_multiplier or 1) + 0.5)),
            bad_count = math.max(0, math.floor(self.level.bad_count * (self.difficulty.bad_food_multiplier or 1) + 0.5)),
        }
        self.goal_good = self.food_counts.good_count
        self.foods = Food.spawn_set(self.level, self.snake, self.food_counts)
        self.speed = self.difficulty.initial_speed or 6
        self.speed_increment = self.difficulty.speed_increment or 0.25
        self.tick_length = 1 / self.speed
        self.tick_timer = 0
        self:update_layout()
        self.quotes:reset(self.level, game.localization)
        game.session.level_stats = {
            good_collected = 0,
            bad_hits = 0,
            time = 0,
            level_name = game.localization:get(self.level.name_key),
            score = 0,
            bonus = 0,
        }
        game.audio:play_music(self.level.music)
    end

    function state:update_layout()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        local usable_width = width - 12
        local usable_height = height - self.hud_height - 12
        local cell = math.floor(math.min(usable_width / self.level.grid_width, usable_height / self.level.grid_height))
        self.grid.cell = math.max(8, cell)

        local grid_width = self.level.grid_width * self.grid.cell
        local grid_height = self.level.grid_height * self.grid.cell
        self.grid.x = math.floor((width - grid_width) * 0.5)
        self.grid.y = self.hud_height + math.floor((usable_height - grid_height) * 0.5) + 6
    end

    function state:update(dt)
        game.session.level_stats.time = game.session.level_stats.time + dt
        game.session.level_stats.score = game.session.score
        self.tick_timer = self.tick_timer + dt
        self.quotes:update(dt)

        local direction = game.input:get_direction_pressed()
        if direction then
            self.snake:set_direction(direction)
        end

        for _, tap in ipairs(game.input:get_taps()) do
            if game:should_show_touch_controls() then
                local touch_direction = self.controls:get_direction_at(
                    tap.x,
                    tap.y,
                    game.renderer.logical_width,
                    game.renderer.logical_height,
                    self.hud_height,
                    game.settings.values.control_layout
                )
                if touch_direction then
                    self.snake:set_direction(touch_direction)
                end
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
                        self.speed = self.speed + self.speed_increment
                        self.tick_length = math.max(0.05, 1 / self.speed)
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

            if game.session.level_stats.good_collected >= self.goal_good then
                game.audio:stop_music()
                game.session.level_stats.score = game.session.score
                game.session.level_stats.bonus = math.max(0, math.floor(250 - game.session.level_stats.time * 8))
                game.session.score = game.session.score + game.session.level_stats.bonus
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
            local scale = self.grid.cell / 8
            local offset = (self.grid.cell - 8 * scale) * 0.5
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                image,
                self.grid.x + food.x * self.grid.cell + offset,
                self.grid.y + food.y * self.grid.cell + offset,
                0,
                scale,
                scale
            )
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
        local width = game.renderer.logical_width
        local quote = self.quotes:get_text()
        local head_frame = self.quotes:is_speaking() and self.quotes:get_frame() or 1
        love.graphics.setColor(0.03, 0.07, 0.11, 0.78)
        love.graphics.rectangle("fill", 0, 0, width, self.hud_height)
        love.graphics.setColor(0.55, 0.75, 0.9, 0.6)
        love.graphics.line(0, self.hud_height, width, self.hud_height)
        love.graphics.setColor(0.95, 0.98, 1, 1)
        love.graphics.print(game.localization:get(self.level.name_key), 8, 5)
        love.graphics.print(game.localization:get("hud_score", { score = game.session.score }), 8, 15)
        love.graphics.print(game.localization:get("hud_lives", { lives = game.session.lives }), 112, 5)
        love.graphics.print(game.localization:get("hud_goal", {
            current = game.session.level_stats.good_collected,
            total = self.goal_good,
        }), 112, 15)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(game.assets:get_image("head"), game.assets:get_head_quad(head_frame), width - 34, 4, 0, 0.36, 0.36)

        if quote then
            love.graphics.setColor(0.08, 0.1, 0.14, 0.84)
            love.graphics.rectangle("fill", width - 142, 2, 92, 28)
            love.graphics.setColor(0.92, 0.96, 1, 0.95)
            love.graphics.rectangle("line", width - 142, 2, 92, 28)
            love.graphics.setColor(0.95, 0.98, 1, 1)
            love.graphics.printf(quote, width - 138, 5, 84, "left")
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        self:update_layout()
        love.graphics.setColor(0.04, 0.06, 0.09, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(0.08, 0.12, 0.16, 1)
        love.graphics.rectangle("fill", 0, self.hud_height, width, height - self.hud_height)
        self:draw_grid()
        self:draw_foods()
        self:draw_snake()
        self:draw_hud()
        if game:should_show_touch_controls() then
            self.controls:draw(game.assets, width, height, self.hud_height, game.settings.values.control_layout)
        end
    end

    return state
end
