function love.conf(t)
    t.identity = "engaged-snake"
    t.version = "11.5"
    t.console = false

    t.window.title = "engaged-snake"
    t.window.width = 256 * 5
    t.window.height = 144 * 5
    t.window.resizable = true
    t.window.minwidth = 256
    t.window.minheight = 144
    t.window.vsync = 1
    t.window.msaa = 0

    t.modules.physics = false
end
