require 'rail'

Bad = {}

function Bad:new(rail)
    local r = rail or SamRail:new(0, 0)

    return setmetatable({
        x = r.x,
        y = r.y,
        dead = false,
        size = 15, 
        rail = r,
        shots = {},

        t = 0
    }, {__index = self})
end

function Bad:advance(dt)
    self.rail:advance(dt)
    self.x = self.rail.x
    self.y = self.rail.y
    self.dead = self.rail.dead 
    self.shots = self.rail.shots
    self.rail.shots = {}

    self.t = self.t + 25 * dt
end

function Bad:collide(bullet)
    if bullet.deadly then
        self.dead = true
    end
end

function Bad:bounds()
    local half_size = self.size / 2
    return {
        x = self.x - half_size, 
        y = self.y - half_size, 
        width = self.size, 
        height = self.size
    } 
end

function Bad:draw()
    local half_size = self.size / 2
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(191, 255, 0)

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.t)
    love.graphics.triangle(
        'line',
        0, half_size,
        half_size, - half_size,
        - half_size, - half_size
    )
    love.graphics.pop()

    love.graphics.setColor(r, g, b, a)
end
