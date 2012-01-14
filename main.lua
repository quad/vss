x, y = 400, 300


joystick = {
    n = 0, 
    axes = {
        lr = 0,
        ud = 1
    },
    sensitivity = 500,
    threshold = 0.25
}

debug = {}

bullets = {}

function love.load(arg)
    love.joystick.open(joystick.n)
end

function axis_update(joystick, axis)
    delta = love.joystick.getAxis(joystick.n, joystick.axes[axis])

    if math.abs(delta) > joystick.threshold then
        return joystick.sensitivity * delta
    else
        return 0
    end
end

function love.joystickpressed(j, b)
    fire_everything = true
end

function love.joystickreleased(j, b)
    fire_everything = false
end

function update_bullets(dt)
    for i, v in ipairs(bullets) do
        v.x = v.x + v.v * math.sin(v.r) * dt
        v.y = v.y - v.v * math.cos(v.r) * dt
    end
end

function update_fire_state(dt)
    if fire_everything then
        table.insert(bullets, {x=x, y=y, v=1000, r=0})
    end
end

function love.update(dt)
    update_fire_state(dt)
    update_bullets(dt)

    x = x + axis_update(joystick, 'lr') * dt
    y = y + axis_update(joystick, 'ud') * dt
end

function love.keypressed(k)
    if k == 'escape' or k == 'q' then
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
