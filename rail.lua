Rail = {}

function Rail:new(duration)
    local d = duration or 5

    return setmetatable({
        x = math.random() * 700 + 25,
        points = points,
        current = d,
        duration = d,
        dead = false
    }, {__index = self})
end

function Rail:advance(dt)
    self.current = self.current - dt

    local period = self.duration / 3

    if self.current < 0 then
        self.dead = true
    elseif self.current < period then
        -- leaving
        self.y = 100 - 100 * (period - self.current) / period
    elseif self.current < period * 2 then
        -- hovering
    elseif self.current < period * 3 then
        -- entering
        self.y = 100 * (self.duration - self.current) / period
    end
end
