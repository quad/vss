Bad = {}

function Bad:new()
    return setmetatable({
        x = 50,
        y = 50,
        state = "enter"
    }, {__index = self})
end

function Bad:update(dt)
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
        local current_color = love.graphics.getColor()
        love.graphics.setColor(math.random() * 255, math.random() * 255, math.random() * 255, self.death_duration * 255)
        love.graphics.circle('fill', self.x, self.y, 50 * self.death_duration)
    end
end
