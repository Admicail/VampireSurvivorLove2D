-- Enemy module
local Enemy = {}
Enemy.__index = Enemy

-- Base stats per wave level
local BASE_HP     = 30
local BASE_SPEED  = 60
local BASE_DAMAGE = 10
local BASE_EXP    = 15
local RADIUS      = 12

function Enemy.new(x, y, wave)
    local self = setmetatable({}, Enemy)
    local scale = 1 + (wave - 1) * 0.2
    self.x      = x
    self.y      = y
    self.hp     = math.floor(BASE_HP    * scale)
    self.maxHp  = self.hp
    self.speed  = BASE_SPEED + wave * 5
    self.damage = math.floor(BASE_DAMAGE * scale)
    self.exp    = math.floor(BASE_EXP   * scale)
    self.radius = RADIUS
    self.alive  = true
    -- Flash timer for hit feedback
    self.hitTimer = 0
    return self
end

function Enemy:update(dt, player)
    if not self.alive then return end

    self.hitTimer = math.max(0, self.hitTimer - dt)

    -- Move toward player
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 1 then
        self.x = self.x + (dx / dist) * self.speed * dt
        self.y = self.y + (dy / dist) * self.speed * dt
    end
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    self.hitTimer = 0.12
    if self.hp <= 0 then
        self.hp    = 0
        self.alive = false
    end
end

function Enemy:draw()
    if not self.alive then return end

    -- Flash white on hit
    if self.hitTimer > 0 then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.9, 0.1, 0.1)
    end
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- Outline
    love.graphics.setColor(0.6, 0, 0)
    love.graphics.circle("line", self.x, self.y, self.radius)

    -- HP bar
    local barW = 28
    local hpRatio = self.hp / self.maxHp
    love.graphics.setColor(0.5, 0, 0)
    love.graphics.rectangle("fill", self.x - barW / 2, self.y - self.radius - 8, barW, 4)
    love.graphics.setColor(1, 0.3, 0)
    love.graphics.rectangle("fill", self.x - barW / 2, self.y - self.radius - 8, barW * hpRatio, 4)
end

return Enemy
