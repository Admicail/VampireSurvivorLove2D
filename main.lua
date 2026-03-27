-- main.lua – entry point for the Vampire Survivor Love2D prototype
local Game = require("src.game")

local game

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(0.08, 0.05, 0.12)
    game = Game.new()
end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    game:keypressed(key)
end

function love.draw()
    game:draw()
end
