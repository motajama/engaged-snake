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

local function load_image_or_placeholder(path, fallback)
    if path and love.filesystem.getInfo(path) then
        local image = love.graphics.newImage(path)
        image:setFilter("nearest", "nearest")
        return image
    end
    return fallback()
end

function Assets:load(dataset)
    self.dataset = dataset
    self.fonts.small = love.graphics.newFont(8, "mono")
    self.fonts.medium = love.graphics.newFont(12, "mono")
    self.fonts.large = love.graphics.newFont(16, "mono")
    self.fonts.title = love.graphics.newFont(24, "mono")

    local width = self.renderer.logical_width
    local height = self.renderer.logical_height

    self.images.title = load_image_or_placeholder(dataset.title_screen and ("datasets/base/" .. dataset.title_screen), function()
        return make_canvas(width, height, function()
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
    end)

    local guide = dataset.characters and dataset.characters.guide or {}
    local guide_frame_w = guide.frame_width or 64
    local guide_frame_h = guide.frame_height or 64
    local guide_frames = guide.frames or 4
    self.images.head = load_image_or_placeholder(guide.sprite and ("datasets/base/" .. guide.sprite), function()
        return make_canvas(guide_frame_w * guide_frames, guide_frame_h, function()
        for frame = 0, guide_frames - 1 do
            local x = frame * guide_frame_w
            love.graphics.setColor(rgb("#2b2d42"))
            love.graphics.rectangle("fill", x, 0, guide_frame_w, guide_frame_h)
            love.graphics.setColor(rgb("#ef233c"))
            love.graphics.rectangle("fill", x + 18, 16, 28, 28)
            love.graphics.setColor(rgb("#edf2f4"))
            love.graphics.rectangle("fill", x + 24 + frame % 2, 24, 6, 6)
            love.graphics.rectangle("fill", x + 34 - frame % 2, 24, 6, 6)
            love.graphics.setColor(rgb("#8d99ae"))
            love.graphics.rectangle("fill", x + 18, 48 - frame, 28, 5)
        end
        end)
    end)

    local head_sheet_w = guide_frame_w * guide_frames
    for frame = 1, guide_frames do
        self.quads[frame] = love.graphics.newQuad((frame - 1) * guide_frame_w, 0, guide_frame_w, guide_frame_h, head_sheet_w, guide_frame_h)
    end

    local faces = dataset.difficulty_faces or {}
    local face_w = faces.frame_w or 64
    local face_h = faces.frame_h or 64
    self.images.difficulty_faces = load_image_or_placeholder(faces.sprite and ("datasets/base/" .. faces.sprite), function()
        return make_canvas(face_w * 4, face_h, function()
        local colors = {
            { "#6c757d", "#f1f3f5" },
            { "#2a9d8f", "#f1faee" },
            { "#e9c46a", "#1d3557" },
            { "#e63946", "#f1faee" },
        }
        for frame = 0, 3 do
            local x = frame * face_w
            local pair = colors[frame + 1]
            love.graphics.setColor(rgb(pair[1]))
            love.graphics.rectangle("fill", x, 0, face_w, face_h)
            love.graphics.setColor(rgb(pair[2]))
            love.graphics.rectangle("fill", x + 16, 16, 32, 32)
            love.graphics.rectangle("fill", x + 22, 24, 6, 6)
            love.graphics.rectangle("fill", x + 36, 24, 6, 6)
            love.graphics.rectangle("fill", x + 22, 42, 20, 4)
        end
        end)
    end)

    self.quads.difficulty_faces = {}
    for frame = 1, 4 do
        self.quads.difficulty_faces[frame] = love.graphics.newQuad((frame - 1) * face_w, 0, face_w, face_h, face_w * 4, face_h)
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

function Assets:get_difficulty_face(index)
    return self.images.difficulty_faces, self.quads.difficulty_faces[(index or 0) + 1] or self.quads.difficulty_faces[1]
end

return Assets
