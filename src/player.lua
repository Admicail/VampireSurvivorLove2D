-- Player module
local Player = {}
Player.__index = Player

local SPEED       = 180   -- pixels per second
local MAX_HP      = 100
local RADIUS      = 14
local LEVEL_EXP   = {100, 250, 450, 700, 1000}  -- exp needed per level

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x      = x
    self.y      = y
    self.hp     = MAX_HP
    self.maxHp  = MAX_HP
    self.radius = RADIUS
    self.speed  = SPEED
    self.exp    = 0
    self.level  = 1
    self.alive  = true
    return self
end

function Player:update(dt, mapW, mapH)
    if not self.alive then return end

    local dx, dy = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up")    then dy = dy - 1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down")  then dy = dy + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left")  then dx = dx - 1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = dx + 1 end

    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
    end

    self.x = math.max(self.radius, math.min(mapW - self.radius, self.x + dx * self.speed * dt))
    self.y = math.max(self.radius, math.min(mapH - self.radius, self.y + dy * self.speed * dt))
end

function Player:gainExp(amount)
    self.exp = self.exp + amount
    local threshold = LEVEL_EXP[self.level] or math.huge
    if self.exp >= threshold and self.level < #LEVEL_EXP + 1 then
        self.exp   = self.exp - threshold
        self.level = self.level + 1
        -- Level-up bonus: restore some HP and increase speed slightly
        self.hp    = math.min(self.maxHp, self.hp + 20)
        self.speed = self.speed + 10
        return true   -- leveled up
    end
    return false
end

function Player:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp    = 0
        self.alive = false
    end
end

function Player:draw()
    if not self.alive then return end

    -- Body
    love.graphics.setColor(0.2, 0.5, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- Outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", self.x, self.y, self.radius)

    -- HP bar (above player)
    local barW = 40
    local hpRatio = self.hp / self.maxHp
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("fill", self.x - barW / 2, self.y - self.radius - 10, barW, 5)
    love.graphics.setColor(0, 0.9, 0)
    love.graphics.rectangle("fill", self.x - barW / 2, self.y - self.radius - 10, barW * hpRatio, 5)
end

return Player
