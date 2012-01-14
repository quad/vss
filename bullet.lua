Bullet = {}

function Bullet:new(x, y, fired_by)
    return setmetatable({
        x = x,
        y = y,
        dead = false,
        fired_by = fired_by,
        radius = 10,
        v = 1000,
        r = 0}, {__index = self})
end

function Bullet:advance(dt)
    self.x = self.x + self.v * math.sin(self.r) * dt
    self.y = self.y - self.v * math.cos(self.r) * dt

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
