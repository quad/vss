Bullet = {}

function Bullet:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        v = 1000,
        r = 0}, {__index = self})
end

function Bullet:update(dt)
    self.x = self.x + self.v * math.sin(self.r) * dt
    self.y = self.y - self.v * math.cos(self.r) * dt
end

function Bullet:draw()
    love.graphics.circle('fill', self.x, self.y, 10)
end

function Bullet:is_offscreen()
    return self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end
