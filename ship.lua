Ship = {}

function Ship:new(x, y, joystick)
    return setmetatable({
        x = x,
        y = y,
        size = 19,
        t = 0,
        joystick = joystick}, {__index = self})
end

function axis_update(joystick, axis)
    delta = love.joystick.getAxis(joystick.n, joystick.axes[axis])

    if math.abs(delta) > joystick.threshold then
        return joystick.sensitivity * delta
    else
        return 0
    end
end

function Ship:advance(dt)
    self.x = self.x + axis_update(joystick, 'lr') * dt
    self.y = self.y + axis_update(joystick, 'ud') * dt
    self.t = self.t + 2 * dt
end

function Ship:bounds()
    return {
        x = self.x, 
        y = self.y, 
        width = 3, 
        height = 3 
    }
end

function Ship:collide()
    self.dead = true
end

function Ship:draw()
    local half_size = math.floor(self.size / 2)

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.t)
    love.graphics.rectangle( 'line', -half_size, -half_size, self.size, self.size)
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(-self.t)
    love.graphics.scale(math.random() + 1 - math.random())
    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()
    love.graphics.setLineWidth(3)
    love.graphics.setColor(
        math.random() * 255,
        math.random() * 255,
        math.random() * 255,
        200)
    love.graphics.rectangle( 'line', -half_size, -half_size, self.size, self.size)
    love.graphics.setLineWidth(w)
    love.graphics.setColor(r, g, b, a)
    love.graphics.pop()

    love.graphics.point(self.x, self.y, 1)
end
