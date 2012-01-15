Rail = {
    x = 0,
    y = 0,
    dead = true,
    shots = {}
}

function Rail:advance(dt)
end

BetaRail = {}

function BetaRail:new(duration)
    local d = duration or 7

    return setmetatable({
        x = math.random() * 700 + 25,
        depth = math.random() * 300,
        current = d,
        duration = d,
        dead = false,
        ready_to_spit = true,
        shots = {}
    }, {__index = self})
end

function BetaRail:advance(dt)
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

function BetaRail:is_hovering()
    return self.current < period * 2
end

SamRail = {}

function SamRail:new(x, y, v, t)
    return setmetatable({
        x = x,
        y = y,
        dead = true,
        shots = {},

        v = v or 100,
        t = t or math.pi * 0.75,
        d = 2
    }, {__index = self})
end

function SamRail:advance(dt)
    self.x = self.x + self.v * math.sin(self.t) * dt
    self.y = self.y - self.v * math.cos(self.t) * dt

    self.d = self.d - dt
    if self.d < 0 then
        self.d = 2
        self.shots = {Bullet:new(self.x, self.y, math.pi, true, 500)}
    end

    self.dead = self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end
