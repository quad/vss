Boom = {}

function Boom:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        duration = 1,
        size = 50,
        dead = false
    }, {__index = self})
end

function Boom:advance(dt)
    self.duration = self.duration - dt

    if self.duration < 0 then
        self.dead = true
    end
end

function Boom:collide()
end

function Boom:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(
        math.random() * 255,
        math.random() * 255,
        math.random() * 255,
        self.duration * 255)

    love.graphics.circle(
        'fill',
        self.x, self.y,
        self.size * self.duration)

    love.graphics.setColor(r, g, b, a)
end
