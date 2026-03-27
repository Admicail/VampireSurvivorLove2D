local bullet = {}
bullet.list = {}

function bullet.spawn(x, y, dx, dy)
    local b = {
        x = x,
        y = y,
        width = 10,
        height = 10,
        speed = 500,
        dx = dx,
        dy = dy
    }
    table.insert(bullet.list, b)
end

function bullet.update(dt)
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]

        b.x = b.x + b.dx * b.speed * dt
        b.y = b.y + b.dy * b.speed * dt

        if b.x < 0 or b.x > love.graphics.getWidth() or
           b.y < 0 or b.y > love.graphics.getHeight() then
            table.remove(bullet.list, i)
        end
    end
end

function bullet.draw()
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(bullet.list) do
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    end
    love.graphics.setColor(1, 1, 1)
end

return bullet