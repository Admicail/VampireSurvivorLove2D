local player = require("player")
local enemy = require("enemy")
local bullet = require("bullet")

local spawnTimer = 0
local spawnInterval = 2

function love.load()
    player.load()
end

function love.update(dt)
    if player.life <= 0 then
        return
    end

    player.update(dt)

    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        enemy.spawn(math.random(0, 850), math.random(0, 550))
    end

    bullet.update(dt)
    enemy.update(dt, player)

    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]

        for j = #enemy.list, 1, -1 do
            local e = enemy.list[j]

            local hit =
                b.x < e.x + e.size and
                b.x + b.width > e.x and
                b.y < e.y + e.size and
                b.y + b.height > e.y

            if hit then
                table.remove(bullet.list, i)
                table.remove(enemy.list, j)
                break
            end
        end
    end
end

function love.draw()
    player.draw()
    enemy.draw()
    bullet.draw()

    love.graphics.print("Vida: " .. math.floor(player.life), 10, 10)

    if player.life <= 0 then
        love.graphics.print("GAME OVER", 400, 300)
    end
end

function love.keypressed(key)
    if player.life <= 0 then return end

    local px = player.x + player.size / 2
    local py = player.y + player.size / 2

    if key == "up" then
        bullet.spawn(px, py, 0, -1)

    elseif key == "down" then
        bullet.spawn(px, py, 0, 1)

    elseif key == "left" then
        bullet.spawn(px, py, -1, 0)

    elseif key == "right" then
        bullet.spawn(px, py, 1, 0)
    end
end