require 'bad'
require 'boom'
require 'bullet'
require 'ship'

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

ships = {}
bullets = {}
baddies = {}
booms = {}
sounds = {}

live = {ships, bullets, baddies}
all = {ships, bullets, baddies, booms}

function love.load(arg)
    love.joystick.open(joystick.n)

    sounds.player_shot = love.audio.newSource("resources/playershoot.ogg", "static")
    sounds.player_shot:setLooping(true)

    ship = Ship:new(400, 300, joystick)
    table.insert(ships, ship)

    for i = 1, 100, 1 do
        table.insert(baddies, Bad:new(math.random() * 700 + 25, math.random() * 100))
    end
end

function add_bad()
end

function love.joystickpressed(j, b)
    fire_everything = true
end

function love.joystickreleased(j, b)
    fire_everything = false
end

function update_bullets()
    if fire_everything then
        if sounds.player_shot:isStopped() then
            sounds.player_shot:play()
        end
        table.insert(bullets, Bullet:new(ship.x, ship.y, 0, true))
    elseif not sounds.player_shot:isStopped() then
        sounds.player_shot:stop()
    end

    for i_bad, bad in ipairs(baddies) do
        for i_s, s in ipairs(bad.shots) do
            table.insert(bullets, s)
        end

        bad.shots = {}
    end
end

function is_colliding(a, b)
    local ax2, ay2, bx2, by2 = a.x + a.width, a.y + a.height, b.x + b.width, b.y + b.height
    return a.x < bx2 and ax2 > b.x and a.y < by2 and ay2 > b.y
end

function collision_detection()
    for i_bad, bad in ipairs(baddies) do
        for i_bullet, bullet in ipairs(bullets) do
            if is_colliding(bullet:bounds(), bad:bounds()) then
                bad:collide(bullet)

                if bad.dead then
                    table.remove(baddies, i_bad)
                    table.insert(booms, Boom:new(bad.x, bad.y))
                end

                table.remove(bullets, i_bullet)
            end
        end
    end
end

function update()
    update_bullets()
    collision_detection()
end

function advance(dt)
    for i_things, things in ipairs(all) do
        for i_t, t in ipairs(things) do
            t:advance(dt)

            if t.dead then
                table.remove(things, i_t)
            end
        end
    end
end

function love.update(dt)
    advance(dt)
    update(dt)
end

function love.keypressed(k)
    if k == 'escape' or k == 'q' then
        love.event.push('q')
    end
end

function love.draw()
    for i, things in ipairs(all) do
        for i, t in ipairs(things) do
            t:draw()
        end
    end

    -- DEBUG
    for i = 1, #debug do
        love.graphics.print("Line " .. i .. ": " .. debug[i], 50, 50 + (i * 10))
    end

    -- Draw the current FPS.
    print_objects(0, love.graphics.getHeight() - 30, 'All', all)
    print_objects(0, love.graphics.getHeight() - 45, 'Live', live)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, love.graphics.getHeight() - 15)
end

function print_objects(x, y, title, objs)
    local n = 0
    for i, v in ipairs(objs) do
        n = n + table.maxn(v)
    end

    love.graphics.print(title .. ":" .. n, x, y)
end
