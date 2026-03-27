local player = {}

function player.load()
    player.x = 450
    player.y = 300
    player.size = 30
    player.speed = 220
    player.life = 100
end

function player.update(dt)
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end

    if player.x < 0 then player.x = 0 end
    if player.y < 0 then player.y = 0 end
    if player.x + player.size > love.graphics.getWidth() then
        player.x = love.graphics.getWidth() - player.size
    end
    if player.y + player.size > love.graphics.getHeight() then
        player.y = love.graphics.getHeight() - player.size
    end
end

function player.draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)
    love.graphics.setColor(1, 1, 1)
end

return player