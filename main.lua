require 'bad'
require 'boom'
require 'bullet'
require 'ship'
require 'wave'

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
bullets_baddies = {}
bullets_ship = {}
baddies = {}
booms = {}
sounds = {}

all = {ships, bullets_baddies, bullets_ship, baddies, booms}

function love.load(arg)
    love.joystick.open(joystick.n)

    sounds.player_shot = love.audio.newSource("resources/playershoot.ogg", "static")
    sounds.player_shot:setLooping(true)

    sounds.bad_boom = love.sound.newSoundData("resources/badboom.ogg")

    sounds.ship_boom = love.audio.newSource("resources/shipboom.ogg", "static")

    ship = Ship:new(400, 300, joystick)
    table.insert(ships, ship)

end

function love.joystickpressed(j, b)
    fire_everything = true
end

function love.joystickreleased(j, b)
    fire_everything = false
end

function fire_baddies()
    for i_bad, bad in ipairs(baddies) do
        for i_s, s in ipairs(bad.shots) do
            table.insert(bullets_baddies, s)
        end

        bad.shots = {}
    end
end

function fire_ship()
    if fire_everything then
        if sounds.player_shot:isStopped() then
            sounds.player_shot:play()
        end
        table.insert(bullets_ship, Bullet:new(ship.x, ship.y, 0, true))
    elseif not sounds.player_shot:isStopped() then
        sounds.player_shot:stop()
    end
end

function is_colliding(a, b)
    local bounds_a, bounds_b = a:bounds(), b:bounds()

    local ax2, ay2 = bounds_a.x + bounds_a.width, bounds_a.y + bounds_a.height
    local bx2, by2 = bounds_b.x + bounds_b.width, bounds_b.y + bounds_b.height
    return bounds_a.x < bx2 and ax2 > bounds_b.x and bounds_a.y < by2 and ay2 > bounds_b.y
end

function move(dt)
    for i_things, things in ipairs(all) do
        for i_t, t in ipairs(things) do
            t:advance(dt)

            if t.dead then
                table.remove(things, i_t)
            end
        end
    end
end

function hit_ship()
    for i_bullet, bullet in ipairs(bullets_baddies) do
        if is_colliding(bullet, ship) then
            bullet:collide(ship)
            ship:collide(bullet)

            if bullet.dead then
                table.remove(bullets_baddies, i_bullet)
            end

            if ship.dead then
                table.insert(booms, Boom:new(ship.x, ship.y))
                sounds.ship_boom:play()
            end
        end
    end
end

function hit_baddies()
    for i_bad, bad in ipairs(baddies) do
        for i_bullet, bullet in ipairs(bullets_ship) do
            if is_colliding(bullet, bad) then
                bullet:collide(bad)
                bad:collide(bullet)

                if bullet.dead then
                    table.remove(bullets_ship, i_bullet)
                end

                if bad.dead then
                    table.remove(baddies, i_bad)
                    table.insert(booms, Boom:new(bad.x, bad.y))

                    local explosion = love.audio.newSource(sounds.bad_boom)
                    explosion:play()
                    break
                end
            end
        end
    end
end

last_spawn = 0

function love.update(dt)
    move(dt)

    hit_ship()
    hit_baddies()

    fire_ship()
    fire_baddies()

    last_spawn = last_spawn - dt

    if last_spawn < 0 then
        last_spawn = 1

        local w = Wave:new()
        for _, b in ipairs(w:spawn()) do
            table.insert(baddies, b)
        end
    end
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
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, love.graphics.getHeight() - 15)
end

function print_objects(x, y, title, objs)
    local n = 0
    for i, v in ipairs(objs) do
        n = n + table.maxn(v)
    end

    love.graphics.print(title .. ":" .. n, x, y)
end
