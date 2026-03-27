-- Game state manager
local Player = require("src.player")
local Enemy  = require("src.enemy")
local Weapon = require("src.weapon")

local Game = {}
Game.__index = Game

local MAP_W = 800
local MAP_H = 600

-- Wave settings
local WAVE_DURATION     = 30    -- seconds per wave
local ENEMIES_PER_WAVE  = 8     -- base enemies spawned each wave
local SPAWN_INTERVAL    = 2.5   -- seconds between spawns within a wave

-- Collision distance between player and enemy (damage tick)
local CONTACT_DAMAGE_INTERVAL = 0.5   -- seconds between contact damage ticks
local CONTACT_DAMAGE          = 10

function Game.new()
    local self = setmetatable({}, Game)
    self:_reset()
    return self
end

function Game:_reset()
    self.state     = "playing"   -- "playing" | "gameover"
    self.player    = Player.new(MAP_W / 2, MAP_H / 2)
    self.weapon    = Weapon.new()
    self.enemies   = {}
    self.score     = 0
    self.wave      = 1
    self.waveTimer = WAVE_DURATION
    self.spawnTimer= 0
    self.contactTimer = 0
    self.spawnedThisWave = 0
    self.maxSpawnThisWave = ENEMIES_PER_WAVE
end

-- Spawn an enemy at a random screen edge
function Game:_spawnEnemy()
    local side = math.random(1, 4)
    local x, y
    if side == 1 then         -- top
        x, y = math.random(0, MAP_W), -20
    elseif side == 2 then     -- bottom
        x, y = math.random(0, MAP_W), MAP_H + 20
    elseif side == 3 then     -- left
        x, y = -20, math.random(0, MAP_H)
    else                      -- right
        x, y = MAP_W + 20, math.random(0, MAP_H)
    end
    table.insert(self.enemies, Enemy.new(x, y, self.wave))
end

function Game:update(dt)
    if self.state == "gameover" then return end

    local player = self.player
    local weapon = self.weapon

    -- ── Wave management ──────────────────────────────────────────────────────
    self.waveTimer = self.waveTimer - dt
    if self.waveTimer <= 0 then
        self.wave             = self.wave + 1
        self.waveTimer        = WAVE_DURATION
        self.spawnedThisWave  = 0
        self.maxSpawnThisWave = ENEMIES_PER_WAVE + (self.wave - 1) * 3
        self.spawnTimer       = 0
    end

    -- ── Enemy spawning ───────────────────────────────────────────────────────
    self.spawnTimer = self.spawnTimer - dt
    if self.spawnTimer <= 0 and self.spawnedThisWave < self.maxSpawnThisWave then
        self:_spawnEnemy()
        self.spawnedThisWave = self.spawnedThisWave + 1
        self.spawnTimer      = SPAWN_INTERVAL
    end

    -- ── Player update ─────────────────────────────────────────────────────────
    player:update(dt, MAP_W, MAP_H)

    -- ── Weapon update & collision ─────────────────────────────────────────────
    weapon:update(dt, player, self.enemies)
    weapon:checkCollisions(self.enemies)

    -- ── Enemy update & rewards ────────────────────────────────────────────────
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e:update(dt, player)
        if not e.alive then
            self.score = self.score + e.exp
            local leveled = player:gainExp(e.exp)
            if leveled then
                weapon:upgradeDamage(5)
                weapon:upgradeFireRate(0.04)
            end
            table.remove(self.enemies, i)
        end
    end

    -- ── Contact damage (player touching enemy) ────────────────────────────────
    self.contactTimer = self.contactTimer - dt
    if self.contactTimer <= 0 then
        for _, e in ipairs(self.enemies) do
            if e.alive then
                local dx = player.x - e.x
                local dy = player.y - e.y
                local r  = player.radius + e.radius
                if dx * dx + dy * dy < r * r then
                    player:takeDamage(CONTACT_DAMAGE)
                    break
                end
            end
        end
        self.contactTimer = CONTACT_DAMAGE_INTERVAL
    end

    -- ── Death check ───────────────────────────────────────────────────────────
    if not player.alive then
        self.state = "gameover"
    end
end

function Game:keypressed(key)
    if self.state == "gameover" and key == "r" then
        self:_reset()
    end
end

-- ── Drawing ────────────────────────────────────────────────────────────────────
function Game:draw()
    -- Background
    love.graphics.setColor(0.08, 0.05, 0.12)
    love.graphics.rectangle("fill", 0, 0, MAP_W, MAP_H)

    -- Grid overlay for depth
    love.graphics.setColor(0.12, 0.08, 0.18)
    local step = 50
    for gx = 0, MAP_W, step do
        love.graphics.line(gx, 0, gx, MAP_H)
    end
    for gy = 0, MAP_H, step do
        love.graphics.line(0, gy, MAP_W, gy)
    end

    -- Entities
    self.weapon:draw()
    for _, e in ipairs(self.enemies) do e:draw() end
    self.player:draw()

    -- HUD
    self:_drawHUD()

    -- Game-over overlay
    if self.state == "gameover" then
        self:_drawGameOver()
    end
end

function Game:_drawHUD()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, MAP_W, 36)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format("Wave: %d   Score: %d   Level: %d   HP: %d/%d   [WASD / Arrows to move]",
            self.wave, self.score, self.player.level, self.player.hp, self.player.maxHp),
        8, 10
    )

    -- Wave timer bar
    local ratio = self.waveTimer / WAVE_DURATION
    love.graphics.setColor(0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", 0, 0, MAP_W, 4)
    love.graphics.setColor(0.4, 0.6, 1)
    love.graphics.rectangle("fill", 0, 0, MAP_W * ratio, 4)
end

function Game:_drawGameOver()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, MAP_W, MAP_H)

    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, MAP_H / 2 - 50, MAP_W, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        string.format("Score: %d   Wave: %d\n\nPress R to restart", self.score, self.wave),
        0, MAP_H / 2, MAP_W, "center"
    )
end

return Game
