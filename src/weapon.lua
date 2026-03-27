-- Weapon / projectile module
local Weapon = {}
Weapon.__index = Weapon

local PROJECTILE_SPEED  = 350
local PROJECTILE_RADIUS = 5
local BASE_DAMAGE       = 25
local BASE_FIRE_RATE    = 0.6   -- seconds between shots
local PROJECTILE_RANGE  = 500   -- max travel distance

-- ── Projectile ────────────────────────────────────────────────────────────────
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, tx, ty, damage)
    local self = setmetatable({}, Projectile)
    local dx = tx - x
    local dy = ty - y
    local dist = math.sqrt(dx * dx + dy * dy)
    self.x       = x
    self.y       = y
    self.vx      = (dx / dist) * PROJECTILE_SPEED
    self.vy      = (dy / dist) * PROJECTILE_SPEED
    self.damage  = damage
    self.radius  = PROJECTILE_RADIUS
    self.alive   = true
    self.traveled = 0
    return self
end

function Projectile:update(dt)
    if not self.alive then return end
    local move = PROJECTILE_SPEED * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.traveled = self.traveled + move
    if self.traveled >= PROJECTILE_RANGE then
        self.alive = false
    end
end

function Projectile:draw()
    if not self.alive then return end
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- ── Weapon ────────────────────────────────────────────────────────────────────
function Weapon.new()
    local self = setmetatable({}, Weapon)
    self.projectiles = {}
    self.fireTimer   = 0
    self.fireRate    = BASE_FIRE_RATE
    self.damage      = BASE_DAMAGE
    return self
end

-- Returns the nearest living enemy, or nil
local function nearestEnemy(px, py, enemies)
    local best, bestDist = nil, math.huge
    for _, e in ipairs(enemies) do
        if e.alive then
            local d = (e.x - px)^2 + (e.y - py)^2
            if d < bestDist then
                bestDist = d
                best = e
            end
        end
    end
    return best
end

function Weapon:update(dt, player, enemies)
    -- Advance fire-rate cooldown
    self.fireTimer = self.fireTimer - dt
    if self.fireTimer <= 0 then
        local target = nearestEnemy(player.x, player.y, enemies)
        if target then
            local p = Projectile.new(player.x, player.y, target.x, target.y, self.damage)
            table.insert(self.projectiles, p)
            self.fireTimer = self.fireRate
        else
            self.fireTimer = 0.1   -- retry quickly when no enemies present
        end
    end

    -- Update existing projectiles
    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        p:update(dt)
        if not p.alive then
            table.remove(self.projectiles, i)
        end
    end
end

-- Check collisions between projectiles and enemies; returns total damage dealt
function Weapon:checkCollisions(enemies)
    local totalDmg = 0
    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        if p.alive then
            for _, e in ipairs(enemies) do
                if e.alive then
                    local dx = p.x - e.x
                    local dy = p.y - e.y
                    local r  = p.radius + e.radius
                    if dx * dx + dy * dy < r * r then
                        e:takeDamage(p.damage)
                        totalDmg = totalDmg + p.damage
                        p.alive = false
                        break
                    end
                end
            end
        end
    end
    return totalDmg
end

function Weapon:draw()
    for _, p in ipairs(self.projectiles) do
        p:draw()
    end
end

-- Upgrade helpers (called on player level-up)
function Weapon:upgradeDamage(amount)
    self.damage = self.damage + (amount or 5)
end

function Weapon:upgradeFireRate(reduction)
    self.fireRate = math.max(0.1, self.fireRate - (reduction or 0.05))
end

return Weapon
