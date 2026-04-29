return function(game)
    local state = {
        selected = 3,
        items = { "baby", "easy", "normal", "death" },
        arrow_timer = 0,
    }

    local function item_rect(index)
        return {
            x = 84,
            y = 74 + (index - 1) * 28,
            w = 164,
            h = 18,
        }
    end

    function state:enter()
        self.arrow_timer = 0
        self.selected = 3
        for index, difficulty_id in ipairs(self.items) do
            if difficulty_id == game.settings.values.difficulty then
                self.selected = index
                break
            end
        end
    end

    function state:confirm(index)
        local difficulty_id = self.items[index]
        game.settings.values.difficulty = difficulty_id
        game.settings:save_now()
        game:start_new_run()
        game.audio:play_sfx(game:get_sfx_id("menu_confirm", "menu_confirm"))
        game.state_machine:change("story")
    end

    function state:update(dt)
        self.arrow_timer = self.arrow_timer + dt
        local direction = game.input:get_direction_pressed()
        if direction == "up" then
            self.selected = self.selected - 1
            if self.selected < 1 then
                self.selected = #self.items
            end
            game.audio:play_sfx(game:get_sfx_id("menu_move", "menu_move"))
        elseif direction == "down" then
            self.selected = self.selected + 1
            if self.selected > #self.items then
                self.selected = 1
            end
            game.audio:play_sfx(game:get_sfx_id("menu_move", "menu_move"))
        end

        if game.input:confirm_pressed() then
            self:confirm(self.selected)
            return
        end

        if game.input:back_pressed() then
            game.state_machine:change("menu")
            return
        end

        for _, tap in ipairs(game.input:get_taps()) do
            for index in ipairs(self.items) do
                local rect = item_rect(index)
                if tap.x >= rect.x and tap.x <= rect.x + rect.w and tap.y >= rect.y and tap.y <= rect.y + rect.h then
                    self.selected = index
                    self:confirm(index)
                    return
                end
            end
        end
    end

    local function draw_arrow(x, y, frame)
        love.graphics.push()
        love.graphics.translate(x, y)
        if frame == 2 then
            love.graphics.rotate(math.pi)
            love.graphics.translate(-10, -10)
        end
        love.graphics.polygon("fill", 0, 5, 10, 0, 10, 10)
        love.graphics.pop()
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        local arrow_frame = math.floor(self.arrow_timer * 6) % 2 + 1

        love.graphics.setColor(0.07, 0.04, 0.02, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(0.25, 0.06, 0.02, 1)
        love.graphics.rectangle("fill", 18, 18, width - 36, height - 36)
        love.graphics.setColor(0.76, 0.2, 0.08, 1)
        love.graphics.rectangle("line", 22, 22, width - 44, height - 44)

        love.graphics.setFont(game.assets:get_font("large"))
        love.graphics.setColor(0.98, 0.88, 0.64, 1)
        love.graphics.printf(game.localization:get("menu.choose_difficulty"), 0, 28, width, "center")

        love.graphics.setFont(game.assets:get_font("medium"))
        for index, difficulty_id in ipairs(self.items) do
            local rect = item_rect(index)
            local profile = game:get_difficulty_profile(difficulty_id)
            local image, quad = game.assets:get_difficulty_face(profile.face_index)
            local selected = index == self.selected

            if selected then
                love.graphics.setColor(0.18, 0.09, 0.04, 1)
                love.graphics.rectangle("fill", rect.x - 14, rect.y - 2, rect.w + 24, rect.h + 4)
                love.graphics.setColor(0.98, 0.84, 0.4, 1)
                draw_arrow(rect.x - 8, rect.y + 5, arrow_frame)
            end

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(image, quad, 34, rect.y - 12, 0, 0.6, 0.6)
            love.graphics.setColor(selected and 0.98 or 0.92, selected and 0.9 or 0.92, selected and 0.45 or 0.98, 1)
            love.graphics.print(game.localization:get(profile.label_key), rect.x + 8, rect.y + 3)
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(0.95, 0.92, 0.82, 1)
        love.graphics.printf(game.localization:get("menu.press_confirm"), 0, height - 26, width, "center")
    end

    return state
end
