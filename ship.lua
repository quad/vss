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

function Ship:update(dt)
    self.x = self.x + axis_update(joystick, 'lr') * dt
    self.y = self.y + axis_update(joystick, 'ud') * dt
end

function Ship:draw()
    love.graphics.rectangle(
        'line', 
        self.x - (self.size / 2), 
        self.y - (self.size / 2), 
        self.size, 
        self.size
    )

    love.graphics.point(self.x, self.y, 1)
end
