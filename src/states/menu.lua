return function(game)
    local state = {
        items = {
            { key = "menu_play", target = "play" },
            { key = "menu_highscore", target = "highscore" },
            { key = "menu_settings", target = "settings_menu" },
        },
        selected = 1,
    }

    local function item_rect(index)
        local width = game.renderer.logical_width
        local item_width = 128
        return {
            x = math.floor((width - item_width) * 0.5),
            y = 116 + (index - 1) * 24,
            w = item_width,
            h = 18,
        }
    end

    function state:activate(index)
        local item = self.items[index]
        if item.target == "play" then
            game:start_new_run()
            game.state_machine:change("story")
        else
            game.state_machine:change(item.target)
        end
    end

    function state:update()
        local direction = game.input:get_direction_pressed()
        if direction == "up" then
            self.selected = self.selected - 1
            if self.selected < 1 then
                self.selected = #self.items
            end
        elseif direction == "down" then
            self.selected = self.selected + 1
            if self.selected > #self.items then
                self.selected = 1
            end
        end

        if game.input:confirm_pressed() then
            self:activate(self.selected)
        end

        for _, tap in ipairs(game.input:get_taps()) do
            for index, _ in ipairs(self.items) do
                local rect = item_rect(index)
                if tap.x >= rect.x and tap.x <= rect.x + rect.w and tap.y >= rect.y and tap.y <= rect.y + rect.h then
                    self.selected = index
                    self:activate(index)
                    return
                end
            end
        end
    end

    function state:draw()
        local width = game.renderer.logical_width
        local height = game.renderer.logical_height
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(game.assets:get_image("title"), 0, 0)

        love.graphics.setFont(game.assets:get_font("medium"))
        for index, item in ipairs(self.items) do
            local rect = item_rect(index)
            local selected = index == self.selected
            if selected then
                love.graphics.setColor(0.97, 0.78, 0.28, 0.95)
                love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
                love.graphics.setColor(0.07, 0.1, 0.14, 1)
            else
                love.graphics.setColor(0.1, 0.14, 0.2, 0.85)
                love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
                love.graphics.setColor(0.92, 0.96, 1, 1)
            end
            love.graphics.printf(game.localization:get(item.key), rect.x, rect.y + 4, rect.w, "center")
        end

        love.graphics.setFont(game.assets:get_font("small"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(game.localization:get("menu_hint"), 0, height - 20, width, "center")
    end

    return state
end
