require 'rail'

Bad = {}

function Bad:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        dead = false,
        rail = Rail:new()
    }, {__index = self})
end

function Bad:advance(dt)
    self.rail:advance(dt)
    self.x = self.rail.x
    self.y = self.rail.y
    self.dead = self.rail.dead 
end

function Bad:collide(bullet)
    self.dead = true
end

function Bad:draw()
    local size = 20

    love.graphics.triangle(
        'line',
        self.x, self.y + (size / 2),
        self.x + (size / 2), self.y - (size / 2),
        self.x - (size / 2), self.y - (size / 2)
    )
end
