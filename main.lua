x, y = 400, 300

joystick = 0
joystick_axis_lr = 0
joystick_axis_ud = 1
joystick_sensitivity = 500

debug = {'lulz'}

function love.load(arg)
    love.joystick.open(joystick)
end

function love.update(dt)
    -- left and 
    debug = {
        love.joystick.getAxis(joystick, 0),
        love.joystick.getAxis(joystick, 1)
    }

    x = x + (joystick_sensitivity * love.joystick.getAxis(joystick, joystick_axis_lr)) * dt
    y = y + (joystick_sensitivity * love.joystick.getAxis(joystick, joystick_axis_ud)) * dt
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('q') -- quit the game
    end 
end

function draw_ship(x, y)
    local size = 20

    love.graphics.rectangle('line', x - (size / 2), y - (size / 2), size, size)
    love.graphics.point(x, y, 1)
end

function love.draw()
    draw_ship(x, y)

    -- Draw the loaded lines.
    for i = 1, #debug do
        love.graphics.print("Line " .. i .. ": " .. debug[i], 50, 50 + (i * 10))
    end
end
