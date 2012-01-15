Ship = {}

function Ship:new(x, y, joystick)
    return setmetatable({
        x = x,
        y = y,
        size = 20,
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
end

function Ship:bounds()
    return {
        x = self.x, 
        y = self.y, 
        width = 1, 
        height = 1
    }
end

function Ship:collide()
end

function Ship:draw()
    local half_size = self.size / 2
    love.graphics.rectangle(
        'line', 
        self.x - half_size, 
        self.y - half_size, 
        self.size, 
        self.size
    )

    love.graphics.point(self.x, self.y, 1)
end
