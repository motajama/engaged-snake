local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(logical_width, logical_height, internal_scale)
    local base_width = logical_width * internal_scale
    local base_height = logical_height * internal_scale
    local canvas = love.graphics.newCanvas(base_width, base_height)
    canvas:setFilter("nearest", "nearest")

    local self = setmetatable({
        logical_width = logical_width,
        logical_height = logical_height,
        internal_scale = internal_scale,
        base_width = base_width,
        base_height = base_height,
        canvas = canvas,
        scale = 1,
        offset_x = 0,
        offset_y = 0,
        screen_width = base_width,
        screen_height = base_height,
    }, Renderer)

    local width, height = love.graphics.getDimensions()
    self:resize(width, height)
    return self
end

function Renderer:resize(width, height)
    self.screen_width = width
    self.screen_height = height

    local scale_x = width / self.base_width
    local scale_y = height / self.base_height
    local scale = math.floor(math.min(scale_x, scale_y))

    if scale < 1 then
        scale = math.min(scale_x, scale_y)
    end

    self.scale = scale
    self.offset_x = math.floor((width - self.base_width * scale) * 0.5)
    self.offset_y = math.floor((height - self.base_height * scale) * 0.5)
end

function Renderer:screen_to_game(x, y)
    local render_x = (x - self.offset_x) / self.scale
    local render_y = (y - self.offset_y) / self.scale
    return render_x / self.internal_scale, render_y / self.internal_scale
end

function Renderer:draw_scene(draw_fn, post_fn)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0.04, 0.05, 0.08, 1)
    love.graphics.push()
    love.graphics.scale(self.internal_scale, self.internal_scale)
    draw_fn()
    love.graphics.pop()
    love.graphics.setCanvas()

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()
    love.graphics.translate(self.offset_x, self.offset_y)

    if post_fn then
        post_fn(self.canvas)
    else
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.canvas, 0, 0, 0, self.scale, self.scale)
    end

    love.graphics.pop()
end

return Renderer
