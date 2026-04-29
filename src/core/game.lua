local StateMachine = require("src.core.state_machine")
local Renderer = require("src.core.renderer")
local Input = require("src.core.input")
local Assets = require("src.core.assets")
local Audio = require("src.core.audio")
local Save = require("src.core.save")
local Localization = require("src.core.localization")
local Settings = require("src.core.settings")
local CRT = require("src.systems.crt")

local Game = {}
Game.__index = Game

function Game.new()
    local renderer = Renderer.new(256, 144)
    local save = Save.new()
    local settings = Settings.new(save)

    local self = setmetatable({
        renderer = renderer,
        input = Input.new(renderer),
        save = save,
        settings = settings,
        localization = Localization.new(),
        assets = Assets.new(renderer),
        audio = nil,
        crt = nil,
        dataset = nil,
        highscores = { entries = {} },
        state_factories = {},
        session = {},
    }, Game)

    self.audio = Audio.new(settings)
    self.crt = CRT.new(renderer)
    self.state_machine = StateMachine.new(self)
    self:register_states()
    return self
end

function Game:register_states()
    self.state_factories.boot = require("src.states.boot")
    self.state_factories.intro = require("src.states.intro")
    self.state_factories.menu = require("src.states.menu")
    self.state_factories.settings_menu = require("src.states.settings_menu")
    self.state_factories.highscore = require("src.states.highscore")
    self.state_factories.story = require("src.states.story")
    self.state_factories.play = require("src.states.play")
    self.state_factories.level_stats = require("src.states.level_stats")
    self.state_factories.game_over = require("src.states.game_over")
    self.state_factories.victory = require("src.states.victory")
end

function Game:load()
    self.input:begin_frame()
    self.state_machine:change("boot")
end

function Game:start_new_run()
    self.session = {
        level_index = 1,
        score = 0,
        lives = self.settings:get_starting_lives(),
        level_stats = {},
    }
end

function Game:update(dt)
    self.crt:update(dt)
    self.state_machine:update(dt)
    self.input:begin_frame()
end

function Game:draw()
    local post = nil
    if self.settings.values.video_mode == "mono_crt" then
        post = function(canvas)
            self.crt:draw(canvas)
        end
    end

    self.renderer:draw_scene(function()
        self.state_machine:draw()
    end, post)
end

function Game:resize(width, height)
    self.renderer:resize(width, height)
end

function Game:keypressed(key, _scancode, isrepeat)
    if not isrepeat then
        self.input:keypressed(key)
    end
end

function Game:keyreleased(key)
    self.input:keyreleased(key)
end

function Game:mousepressed(x, y)
    self.input:pointerpressed(x, y)
end

function Game:touchpressed(_id, x, y)
    local width, height = love.graphics.getDimensions()
    self.input:pointerpressed(x * width, y * height)
end

return Game
