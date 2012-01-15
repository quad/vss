require 'rail'

Bad = {}

function Bad:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        dead = false,
        size = 15, 
        rail = SamRail:new(x, y),
        shots = {}
    }, {__index = self})
end

function Bad:advance(dt)
    self.rail:advance(dt)
    self.x = self.rail.x
    self.y = self.rail.y
    self.dead = self.rail.dead 
    self.shots = self.rail.shots
    self.rail.shots = {}
end

function Bad:collide(bullet)
    if bullet.deadly then
        self.dead = true
    end
end

function Bad:bounds()
    local half_size = self.size / 2
    return {
        x = self.x - half_size, 
        y = self.y - half_size, 
        width = self.size, 
        height = self.size
    } 
end

function Bad:draw()
    local half_size = self.size / 2
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(191, 255, 0)
    love.graphics.triangle(
        'line',
        self.x, self.y + half_size,
        self.x + half_size, self.y - half_size,
        self.x - half_size, self.y - half_size
    )
    love.graphics.setColor(r, g, b, a)
end
