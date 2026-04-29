local VirtualControls = {}
VirtualControls.__index = VirtualControls

function VirtualControls.new()
    return setmetatable({}, VirtualControls)
end

function VirtualControls:get_buttons()
    return {
        up = { x = 28, y = 89, w = 28, h = 20 },
        left = { x = 4, y = 109, w = 28, h = 20 },
        down = { x = 28, y = 109, w = 28, h = 20 },
        right = { x = 52, y = 109, w = 28, h = 20 },
    }
end

function VirtualControls:get_direction_at(x, y)
    for direction, rect in pairs(self:get_buttons()) do
        if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
            return direction
        end
    end
    return nil
end

function VirtualControls:draw(assets)
    love.graphics.setFont(assets:get_font("small"))
    for direction, rect in pairs(self:get_buttons()) do
        love.graphics.setColor(0.1, 0.16, 0.22, 0.75)
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 3, 3)
        love.graphics.setColor(0.75, 0.85, 0.95, 1)
        love.graphics.rectangle("line", rect.x + 0.5, rect.y + 0.5, rect.w - 1, rect.h - 1, 3, 3)
        love.graphics.printf(direction:upper(), rect.x, rect.y + 6, rect.w, "center")
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return VirtualControls
