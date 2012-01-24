Bullet = {}

function Bullet:new(x, y, theta, deadly, v)
    return setmetatable({
        x = x,
        y = y,
        dead = false,
        deadly = deadly or false,
        size = 5,
        v = v or 1000,
        theta = theta or math.pi}, {__index = self})
end

function Bullet:advance(dt)
    self.x = self.x + self.v * math.sin(self.theta) * dt
    self.y = self.y - self.v * math.cos(self.theta) * dt

    if self:is_offscreen() then
        self.dead = true
    end
end

function Bullet:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(174, 0, 68)
    love.graphics.rectangle(
        'fill', 
        self.x, 
        self.y, 
        self.size,
        self.size
    )

    love.graphics.setColor(r, g, b, a)
end

function Bullet:collide()
end

function Bullet:box()
    return {
        x = self.x - self.size,
        y = self.y - self.size,
        width = self.size * 2,
        height = self.size * 2
    }
end

function Bullet:is_offscreen()
    return self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end
