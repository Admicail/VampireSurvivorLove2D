local enemy = {}
enemy.list = {}

function enemy.spawn(x, y)
    local e = {
        x = x,
        y = y,
        size = 25,
        speed = 100
    }
    table.insert(enemy.list, e)
end

function enemy.update(dt, player)
    for _, e in ipairs(enemy.list) do
        local dx = player.x - e.x
        local dy = player.y - e.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist > 0 then
            e.x = e.x + (dx / dist) * e.speed * dt
            e.y = e.y + (dy / dist) * e.speed * dt
        end

        local touching =
            e.x < player.x + player.size and
            e.x + e.size > player.x and
            e.y < player.y + player.size and
            e.y + e.size > player.y

        if touching then
            player.life = player.life - 20 * dt
        end
    end
end

function enemy.draw()
    love.graphics.setColor(1, 0, 0)
    for _, e in ipairs(enemy.list) do
        love.graphics.rectangle("fill", e.x, e.y, e.size, e.size)
    end
    love.graphics.setColor(1, 1, 1)
end

return enemy