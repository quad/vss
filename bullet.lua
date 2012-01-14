Bullet = {}

function Bullet:new(x, y, fired_by)
    return setmetatable({
        x = x,
        y = y,
        fired_by = fired_by,
        radius = 10,
        v = 1000,
        r = 0}, {__index = self})
end

function Bullet:update(dt)
    self.x = self.x + self.v * math.sin(self.r) * dt
    self.y = self.y - self.v * math.cos(self.r) * dt
end

function Bullet:hits(thing)
    abs_x = math.abs(self.x - thing.x)
    abs_y = math.abs(self.y - thing.y)
    distance = math.sqrt(math.pow(abs_x, 2) + math.pow(abs_y, 2))
    return distance < self.radius
end

function Bullet:draw()
    love.graphics.circle('fill', self.x, self.y, self.radius)
end

function Bullet:is_offscreen()
    return self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end
