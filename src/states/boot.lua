local Json = require("src.util.json")

return function(game)
    local state = {}

    function state:enter()
        local content = assert(love.filesystem.read("datasets/base/dataset.json"), "dataset missing")
        game.dataset = Json.decode(content)
        game.localization:load(game.dataset)
        game.settings:load()
        game.localization:set_language(game.settings.values.language)
        game.assets:load(game.dataset)
        game.highscores = game.save:load_highscores()
        game.state_machine:change("intro")
    end

    function state:update()
    end

    function state:draw()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            "BOOTING...",
            0,
            math.floor(game.renderer.logical_height * 0.48),
            game.renderer.logical_width,
            "center"
        )
    end

    return state
end
