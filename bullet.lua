Bullet = {}

function Bullet:new(x, y, theta, deadly)
    return setmetatable({
        x = x,
        y = y,
        dead = false,
        deadly = deadly or false,
        radius = 5,
        v = 1000,
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
    love.graphics.circle('fill', self.x, self.y, self.radius)
end

function Bullet:is_offscreen()
    return self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end
