Bad = {}

function Bad:new()
    return setmetatable({
        x = 50,
        y = 50,
        state = "enter"
    }, {__index = self})
end

function Bad:update(dt)
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
