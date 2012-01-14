x, y = 400, 300

joystick = 0
joystick_axis_lr = 0
joystick_axis_ud = 1
joystick_sensitivity = 500
joystick_threshold = 0.25

debug = {}

bullets = {}

function love.load(arg)
    love.joystick.open(joystick)
end

function axis_update(joystick, axis)
    delta = love.joystick.getAxis(joystick, axis)

    if math.abs(delta) > joystick_threshold then
        return joystick_sensitivity * delta
    else
        return 0
    end
end

function love.joystickpressed(j, b)
    table.insert(bullets, {x=x, y=y, v=1, r=0})
end

function love.update(dt)
    x = x + axis_update(joystick, joystick_axis_lr) * dt
    y = y + axis_update(joystick, joystick_axis_ud) * dt
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('q')
    end 
end

function draw_ship(x, y)
    local size = 20

    love.graphics.rectangle('line', x - (size / 2), y - (size / 2), size, size)
    love.graphics.point(x, y, 1)
end


function draw_bullets()
    for i,v in ipairs(bullets) do 
        love.graphics.circle('fill', v.x, v.y, 10)
    end
end

function love.draw()
    draw_ship(x, y)
    draw_bullets()

    -- DEBUG
    for i = 1, #debug do
        love.graphics.print("Line " .. i .. ": " .. debug[i], 50, 50 + (i * 10))
    end
end
