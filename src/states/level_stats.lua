local Levels = require("src.systems.levels")
local AnimatedCounter = require("src.systems.animated_counter")

return function(game)
    local state = {
        level = nil,
        lines = {},
        current_line = 1,
        tick_timer = 0,
        finished = false,
    }

    function state:enter()
        self.level = Levels.get_level(game.dataset, game.session.level_index)
        local stats = game.session.level_stats
        self.lines = {
            {
                label = game.localization:get("stats_level", { level = stats.level_name or game.localization:get(self.level.name_key) }),
                value = nil,
            },
            {
                label = game.localization:get("stats_good", { value = "" }),
                counter = AnimatedCounter.new(stats.good_collected or 0, 50),
                key = "stats_good",
            },
            {
                label = game.localization:get("stats_bad", { value = "" }),
                counter = AnimatedCounter.new(stats.bad_hits or 0, 35),
                key = "stats_bad",
            },
            {
                label = game.localization:get("stats_lives", { value = "" }),
                counter = AnimatedCounter.new(game.session.lives or 0, 20),
                key = "stats_lives",
            },
            {
                label = game.localization:get("stats_time", { value = "" }),
                counter = AnimatedCounter.new(math.floor((stats.time or 0) * 10 + 0.5), 60, function(value)
                    return string.format("%.1f", value / 10)
                end),
                key = "stats_time",
                suffix = "s",
            },
            {
                label = game.localization:get("stats_score", { value = "" }),
                counter = AnimatedCounter.new(stats.score or game.session.score or 0, 350),
                key = "stats_score",
            },
            {
                label = game.localization:get("stats_bonus", { value = "" }),
                counter = AnimatedCounter.new(stats.bonus or 0, 200),
                key = "stats_bonus",
            },
        }
        self.current_line = 2
        self.tick_timer = 0
        self.finished = false
    end

    function state:update(dt)
        if game.input:back_pressed() then
            game.state_machine:change("menu")
            return
        end

        if not self.finished then
            local line = self.lines[self.current_line]
            if line and line.counter then
                local changed, done = line.counter:update(dt)
                if changed then
                    self.tick_timer = self.tick_timer + dt
                    if self.tick_timer >= 0.045 then
                        self.tick_timer = 0
                        game.audio:play_sfx(game.dataset.sfx.stats_tick or "stats_tick")
                    end
                end

                if done then
                    line.value = line.counter:get_display_value()
                    game.audio:play_sfx(game.dataset.sfx.stats_done or "stats_done")
                    self.current_line = self.current_line + 1
                    self.tick_timer = 0
                    if self.current_line > #self.lines then
                        self.finished = true
                    end
                end
            else
                self.finished = true
            end
            return
        end

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
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(0.06, 0.03, 0.02, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(0.29, 0.07, 0.02, 1)
        love.graphics.rectangle("fill", 24, 24, width - 48, height - 48)
        love.graphics.setColor(0.96, 0.62, 0.18, 1)
        love.graphics.rectangle("line", 28, 28, width - 56, height - 56)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(0.98, 0.87, 0.62, 1)
        love.graphics.printf(game.localization:get("stats_title"), 0, 36, width, "center")
        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.printf(game.localization:get("stats_status"), 0, 56, width, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        for index, line in ipairs(self.lines) do
            local y = 80 + (index - 1) * 20
            love.graphics.setColor(0.95, 0.92, 0.82, 1)
            if line.counter then
                local display_value = index < self.current_line and (line.value or "0") or "0"
                if index == self.current_line and not self.finished then
                    display_value = line.counter:get_display_value()
                end
                local text = game.localization:get(line.key, { value = display_value .. (line.suffix or "") })
                love.graphics.printf(text, 54, y, width - 108, "left")
            else
                love.graphics.printf(line.label, 54, y, width - 108, "left")
            end
        end

        if self.finished then
            love.graphics.setFont(game.assets:get_font("small"))
            love.graphics.setColor(0.98, 0.88, 0.62, 1)
            love.graphics.printf(game.localization:get("stats_ready"), 0, height - 34, width, "center")
        end
    end

    return state
end
