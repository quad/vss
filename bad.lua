Bad = {}

function Bad:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        state = "enter"
    }, {__index = self})
end

function Bad:advance(dt)
    if self.state == "dying" then
        self.death_duration = self.death_duration - dt

        if self.death_duration < 0 then
            self.state = "dead"
        end
    end
end

function Bad:hit(bullet)
    self.state = "dying"
    self.death_duration = 1
end

function Bad:draw()
    local size = 20

    if self.state == "enter" then
        love.graphics.triangle(
            'line',
            self.x, self.y + (size / 2),
            self.x + (size / 2), self.y - (size / 2),
            self.x - (size / 2), self.y - (size / 2)
        )
    elseif self.state == "dying" then 
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(math.random() * 255, math.random() * 255, math.random() * 255, self.death_duration * 255)
        love.graphics.circle('fill', self.x, self.y, 50 * self.death_duration)
        love.graphics.setColor(r, g, b, a)
    end
end
