Bad = {}

function Bad:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        dead = false
    }, {__index = self})
end

function Bad:advance(dt)
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
