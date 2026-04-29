local Assets = {}
Assets.__index = Assets

local function rgb(hex)
    return {
        tonumber(hex:sub(2, 3), 16) / 255,
        tonumber(hex:sub(4, 5), 16) / 255,
        tonumber(hex:sub(6, 7), 16) / 255,
        1,
    }
end

function Assets.new(renderer)
    return setmetatable({
        renderer = renderer,
        images = {},
        quads = {},
        fonts = {},
        palette = {
            bg = rgb("#101820"),
            panel = rgb("#203040"),
            accent = rgb("#f9c74f"),
            accent2 = rgb("#90be6d"),
            danger = rgb("#f94144"),
            text = rgb("#f1f5f9"),
            mute = rgb("#94a3b8"),
        },
    }, Assets)
end

local function make_canvas(width, height, painter)
    local canvas = love.graphics.newCanvas(width, height)
    canvas:setFilter("nearest", "nearest")
    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    painter()
    love.graphics.setCanvas()
    love.graphics.pop()
    return canvas
end

function Assets:load(dataset)
    self.dataset = dataset
    self.fonts.small = love.graphics.newFont(8, "mono")
    self.fonts.medium = love.graphics.newFont(12, "mono")
    self.fonts.large = love.graphics.newFont(16, "mono")
    self.fonts.title = love.graphics.newFont(24, "mono")

    local width = self.renderer.logical_width
    local height = self.renderer.logical_height

    self.images.title = make_canvas(width, height, function()
        love.graphics.clear(0.08, 0.1, 0.14, 1)
        love.graphics.setColor(rgb("#1d3557"))
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(rgb("#457b9d"))
        local columns = math.floor(width / 20)
        for i = 0, columns do
            local x = i * 20
            love.graphics.rectangle("fill", x, height - 48 + (i % 2) * 5, 20, 48)
        end
        love.graphics.setColor(rgb("#a8dadc"))
        love.graphics.circle("fill", width - 34, 38, 16)
        love.graphics.setColor(rgb("#f1faee"))
        love.graphics.setFont(self.fonts.title)
        love.graphics.printf(dataset.title or "ENGAGED SNAKE", 0, 38, width, "center")
        love.graphics.setFont(self.fonts.medium)
        love.graphics.printf("DATA-DRIVEN LOVE2D SLICE", 0, 68, width, "center")
    end)

    self.images.head = make_canvas(256, 64, function()
        for frame = 0, 3 do
            local x = frame * 64
            love.graphics.setColor(rgb("#2b2d42"))
            love.graphics.rectangle("fill", x, 0, 64, 64)
            love.graphics.setColor(rgb("#ef233c"))
            love.graphics.rectangle("fill", x + 18, 16, 28, 28)
            love.graphics.setColor(rgb("#edf2f4"))
            love.graphics.rectangle("fill", x + 24 + frame % 2, 24, 6, 6)
            love.graphics.rectangle("fill", x + 34 - frame % 2, 24, 6, 6)
            love.graphics.setColor(rgb("#8d99ae"))
            love.graphics.rectangle("fill", x + 18, 48 - frame, 28, 5)
        end
    end)

    for frame = 1, 4 do
        self.quads[frame] = love.graphics.newQuad((frame - 1) * 64, 0, 64, 64, 256, 64)
    end

    self.images.good_food = make_canvas(8, 8, function()
        love.graphics.setColor(rgb("#ffd166"))
        love.graphics.rectangle("fill", 1, 1, 6, 6)
        love.graphics.setColor(rgb("#ef476f"))
        love.graphics.rectangle("fill", 3, 0, 2, 2)
    end)

    self.images.bad_food = make_canvas(8, 8, function()
        love.graphics.setColor(rgb("#118ab2"))
        love.graphics.rectangle("fill", 1, 1, 6, 6)
        love.graphics.setColor(rgb("#073b4c"))
        love.graphics.line(1, 1, 6, 6)
        love.graphics.line(6, 1, 1, 6)
    end)
end

function Assets:get_font(name)
    return self.fonts[name]
end

function Assets:get_image(name)
    return self.images[name]
end

function Assets:get_head_quad(frame)
    return self.quads[frame]
end

return Assets
