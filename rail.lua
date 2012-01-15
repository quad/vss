Rail = {}

function Rail:new(duration)
    local d = duration or 7

    return setmetatable({
        x = math.random() * 700 + 25,
        depth = math.random() * 300,
        points = points,
        current = d,
        duration = d,
        dead = false,
        ready_to_spit = true,
        shots = {}
    }, {__index = self})
end

function Rail:advance(dt)
    self.current = self.current - dt

    local period = self.duration / 3

    if self.current < 0 then
        self.dead = true
    elseif self.current < period then
        -- leaving
        self.y = self.depth - self.depth * (period - self.current) / period
    elseif self.current < period * 2 then
        -- hovering
        if self.ready_to_spit then
            self.shots = {Bullet:new(self.x, self.y)}
            self.ready_to_spit = false
        end
    elseif self.current < period * 3 then
        -- entering
        self.y = self.depth * (self.duration - self.current) / period
    end
end

function Rail:is_hovering()
    return self.current < period * 2
end
